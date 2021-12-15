# Disaster recovery


This documentation covers two disaster scenario

- [Data loss](#data-loss)
- [Loss of database instance](#loss-of-database-instance)

In case of any above database disaster, please do the following:

### Freeze pipeline

Alert all developers that, no one should merge to main branch.

### Maintenance mode

In the instance of data loss, if the application is unavailable, the CDN may be forwarding requests to the [offline site](offline-site.md).
If the application is still available and there is a risk of users adding data, enable [Maintenance mode](maintenance-mode.md).

### setup virtual meeting

Set up virtual meeting via Zoom, Slack, Teams or Google Hangout, inviting all the relevant technical stakeholders. Regularly provide updates on
the #tv_product Slack channel; to keep product owners abreast of developments.


## Data loss

In the case of a data loss, we need to recover the data as soon as possible in order to resume normal service. Declare a major incident
and document the incident timelines as you go along.

The application's database is a postgres instance, which resides on PaaS. This provides a point-in-time backup with
the resolution of 1 second, available between 5min and 7days ago - this is not applicable to postgres `tiny` plans. We can use
terraform to create a new database using a point-in-time backup of the affacted database instance.

### Make note of database failure time

Make note of the time the database failure occurred, and then use this to calculate when the integrity of the data in the database was still viable. For instance,
if data loss or corruption happened at 1200hrs, use this to work out what snapshot time is best for the product (consult with the PM if you are unsure what would be best from the product perspective). This would determine the value of `SNAPSHOT_TIME` env.

___Important___: You should convert the time to UTC before actually using it. When you record the time, note what timezone you are using. Especially during BST (British Summer Time).

### Get affected postgres database ID

Use the makefile's `get-postgres-instance-guid` to get the database guid, use the following command:

```
make <env> get-postgres-instance-guid passcode=xxxx [CONFIRM_PRODUCTION=true]
```

`env` is the target environment e.g. `production`


### Rename postgres database instance service

Rename the affected database instance so a new database can be recreated with the production name. To achieve this, run the following make command

```
make <env> rename-postgres-service passcode=xxxx [CONFIRM_PRODUCTION=true]
```
this renames the database by appending "-old" to the database name, `env` is the target environment e.g. `production`

### Remove affected postgres database instance from terraform state file

In order for terraform to be able to create a new database instance, the existing database reference needs to be removed from the state file. This is to ensure it is no longer managed by terraform, otherwise, terraform would revert our changes. To achieve this, use the makefile target -

```
aws-vault login # authenticate to AWS because statefile is on S3
aws-vault exec Deployments --  make <env> remove-postgres-tf-state [CONFIRM_PRODUCTION=true]
```

`env` is the target environment e.g. `production`

### Restore postgres database instance

The following variables need to be set: `DB_INSTANCE_GUID` (the output of [the 'Get affected postgres instance guid' step](#get-affected-postgres-database-id), `SNAPSHOT_TIME` ("2021-09-14 16:00:00" IMPORTANT - this is UTC time!), `passcode` (a [GOV.UK PaaS one-time passcode](https://login.london.cloud.service.gov.uk/passcode)), `CONFIRM_PRODUCTION` (true) and `tag` (cf app teaching-vacancies-qa | grep "docker image" the tag is after the : i.e ghcr.io/dfe-digital/teaching-vacancies:main-7b736906654cbd42145420ad40fcbc6ec257bd1c)

 Use the following makefile command to initiate the restore process by using the approriate variable values:
 ```
 aws-vault login # authenticate to AWS because statefile is on S3
 aws-vault exec Deployments -- make <env> restore-postgres DB_INSTANCE_GUID=abcdb262-79d1-xx1x-b1dc-0534fb9b4 SNAPSHOT_TIME="2021-11-16 15:20:00" \
 passcode=xxxxx tag=xxxx [CONFIRM_PRODUCTION=true]
 ```
 `env` is the target environment e.g. `production`. This will create a new database instance but with a point-in-time database backup of affected database. The restore process could take between 30min - 1hr, use the following to command to get progress:

 ```
cf service teaching-vacancies-postgres-production
 ```

 ### PaaS documention

 Gov UK PaaS Documentation on Point-in-time database recovery can be found [here](https://docs.cloud.service.gov.uk/deploying_services/postgresql/#restoring-a-postgresql-service-from-a-point-in-time)

 ### Tidy up

 Once the database has been successfully restored, the corrupted database instance should be deleted.

 `cf delete-service teaching-vacancies-<env>-old -f`

## Loss of database instance

In case the database instance is lost, the objectives are:

- Recreate the lost postgress database instance
- Restore data from daily backup

### Recreate the lost postgress database instance

In order to recreate the lost postgress database instance, use the following make recipes `terraform-app-plan` and `terraform-app-apply`:

```
make <env> terraform-app-plan passcode=MyPasscode tag=master-08406f04dd9eadb7df6fcda5213be880d7df37ed-20201022090714 ## to see the proposed changes.
```

```
make <env> terraform-app-apply passcode=MyPasscode tag=master-08406f04dd9eadb7df6fcda5213be880d7df37ed-20201022090714 ## apply proposed changes i.e. create new database instance.
```
This will create a new postgres database instance as described in the terraform configuration file.

### Restore Data From Daily Backup

Once the lost database instance has been recreated, the last daily backup will need to be restored. To achieve this, use the following makefile recipe `restore-daily-backup`.

This will, download the latest daily backup from AWS and then florish the new database with data.
