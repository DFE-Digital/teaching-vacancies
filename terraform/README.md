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

## Setup an environment

1. Create 2 certificates:
    1. CloudFront: Request an SSL certificate with AWS Certificate Manager in the 'N. Virginia (us-east-1)' region.
    2. ALB: Request an SSL certificate with AWS Certificate Manager in the region in which you are launching the infrastructure. eg eu-west-2

2. Find or create the Bucket that will store the state of Terraform. Go to S3 and create a bucket with a globally unique name:

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

## Setup a testing pipeline

To enable CI to give us test feedback on our GitHub pull requests we can do a small piece of manual set up:  

1. Create a new CodeBuild project in AWS
2. Name it eg. `tvs2-pull-requests`. You can call it anything you like but bear in mind it is not environment or workspace related, there's one per repository
3. Connect it to your GitHub repository
4. Set Git clone depth to `1`
5. Ensure `Rebuild every time a code change is pushed to this repository` is ticked
6. Tick `Use an image managed by AWS CodeBuild`
7. Select `Ubuntu` for OS
8. Select `Docker` for Runtime
9. Tick `Enable this flag if you want to build Docker images or want your builds to get elevated privileges.`
10. Select `Use the buildspec.yml in the source code root directory`
11. Provide the file name for what the CodeBuild process should run, ours is in `testspec.yml` and is a subset of `buildspec.yml`
12. Select `Do not install any certificate`
13. Select `No artifacts` from the drop down
14. Select `No cache` from the drop down
15. Select `Create a service role in your account`
16. Select `No VPC`
17. Open advanaced settings
18. Lower the build timeout from 1 hour to 15 minutes
