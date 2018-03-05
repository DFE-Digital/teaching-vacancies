# Terraform

This terraform configuration will create an AWS stack.

Resources included:
- CodePipeline
- CodeBuild
- CodeDeploy
- ECR Docker registry
- CloudFront
- VPC, 2 public subnets, 2 private subnets in 2 availability zones
- Postgres via RDS
- ElasticSearch
- CloudWatch
- EC2 instances
- Autoscaling configuration

## Setup

1. Create a certificate

2. Find or create the Bucket that will store Terraform it's state in. Go to S3 and create a bucket with a globally unique name:

Ensure the bucket has the following policy, adding more or less users as required:
```
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::<AWS ACCOUNT ID>:user/<USER NAME>"
            },
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::<INSERT PROJECT NAME>"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::<AWS ACCOUNT ID>:user/<USER NAME>"
            },
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::<INSERT PROJECT NAME>/staging/terraform.tfstate",
                "arn:aws:s3:::<INSERT PROJECT NAME>/production/terraform.tfstate"
            ]
        }
    ]
}
```

3. Copy across the variable template from workspace-variables

```
$ cp workspace-variables/staging.tfvars.example workspace-variables/staging.tfvars
$ cp workspace-variables/production.tfvars.example workspace-variables/production.tfvars
```

4. Initialise Terraform
For the first time you are working with Terraform you'll need to run:
```
$ terraform init
```

5. Create the and select the correct workspaces

  Workspaces allow the Terraform commands to be run with different states, giving them a degree of isolation. Eg. you can create a test workspace

```
$ terraform workspace create staging
$ terraform workspace create production
$ terraform workspace select staging
```

6. Plan what Terraform will do to ensure there are no errors

```
$ terraform plan -var-file=workspace-variables/staging.tfvars
```

7. Apply Terraform changes
```
$ terraform apply -var-file=workspace-variables/staging.tfvars
```
