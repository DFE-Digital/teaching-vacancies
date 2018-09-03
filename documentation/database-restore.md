# Restore the RDS database

[Why not Terraform?](#why-not-terraform)

## Before you start
Ensure you have the correct AWS Client credentials on your machine:

```
cat ~/.aws/credentials
```

This file should contain credentials from your user in AWS IAM (eg. https://console.aws.amazon.com/iam/home?region=eu-west-2#/users/hippers?section=security_credentials) and should look something like this:

```
[default]
aws_access_key_id = <redacted>
aws_secret_access_key = <redacted>
```

## Create a new RDS instance in AWS

### 1. Find the RDS instance we want to restore

Note down the values for the target RDS instance that needs restoring using this command:

```
aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier,Endpoint.Address,DBSubnetGroup.DBSubnetGroupName]' --region eu-west-2
```

### 2. Find the snapshot we want to restore from and note the DBSnapshotIdentifier
```
aws rds describe-db-snapshots --db-instance-identifier <DBInstanceIdentifier> --query 'DBSnapshots[*].[DBSnapshotIdentifier,DBInstanceIdentifier,SnapshotCreateTime]' --region eu-west-2
```

### 3. Create a new RDS instance from the desired snapshot

```
aws rds restore-db-instance-from-db-snapshot --db-instance-identifier '<new_db_identifier>' --db-snapshot-identifier '<DBSnapshotIdentifier>' --db-subnet-group-name '<DBSubnetGroup.DBSubnetGroupName>' --region eu-west-2
```

Once the RDS instance is launched, note the new endpoint address (Either through the console or describing the RDS instances using the command from step 1)

Manually modify the database through the console and add the security group `<environment>-default-sg`.

### 4. Take a database dump from the new RDS instance

You'll need to SSH into one of the ECS instances to pg_dump the database. To list the instances:

```
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`].Value,PublicDnsName]' --region eu-west-2 --filter "Name=tag:Name,Values=*<environment>"
```

SSH into the instance and take a dump:

```
ssh ec2-user@<PublicDnsName>
docker run -i postgres /usr/bin/pg_dump -F tar -h <new-rds-endpoint> -U dxw <database-name> > <environment>-backup-<datetime>.tar
```
### 5. Apply the database dump to the old RDS instance

```
docker run -it -v ${PWD}/<environment>-backup-<datetime>.tar:/backup.tar postgres /bin/bash -c "pg_restore -h <Endpoint.Address> -U dxw -d <database-name> /backup.tar"
```

### 6. Reindex ElasticSearch so listings appear

Visit [AWS ECS](https://eu-west-2.console.aws.amazon.com/ecs/home?region=eu-west-2#/taskDefinitions) and execute the `web_reindex_vacancies_task` for the appropriate environment. This normally takes less than a minute.

### 7. Remove temporary new RDS instance

```
aws rds delete-db-instance --db-instance-identifier <new-rds-identifier> --final-db-snapshot-identifier <new-rds-identifier>-final --region eu-west-2
```

---

## Why not Terraform?
We've chosen not to use Terraform for this task due to issues we ran into when using it. As we expect the occurrence of this operation to be very unlikely, we are happy to not use it given the obstacles:

1. the data wasn't successfully restored on first attempt using https://www.terraform.io/docs/providers/aws/r/db_instance.html#snapshot_identifier all the tables were empty
2. the snapshot identifier would need to be added to the terraform code by variables or hardcoded in, when removed Terraform will detect an internal diff and create a brand new instance without data
3. when Terraform deletes the RDS instance to replace from snapshot it removes **all** previous snapshots, we do not know why
