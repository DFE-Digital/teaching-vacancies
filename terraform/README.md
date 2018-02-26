1. Create the Bucket that will store Terraform state
Go to S3 and create a bucket with the name of your project that will need to match the project_name you provide to Terraform:

Click into the new bucket and add the following Bucket Policy:
```
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::530003481352:user/hippers"
            },
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::<INSERT PROJECT NAME>"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::530003481352:user/hippers"
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

2. Copy across the variable template from workspace-variables

```
$ cp workspace-variables/staging.tfvars.example workspace-variables/staging.tfvars
$ cp workspace-variables/production.tfvars.example workspace-variables/production.tfvars
```

3. Initialise Terraform
```
$ terraform init
```

4. Create the and select the correct workspaces

Workspaces allow Terraform commands to be run on a different scope meaning there's a new blank Terraform state for us to manage different environments:

```
$ terraform workspace create staging
$ terraform workspace create production
$ terraform workspace select staging
```

5. Plan what Terraform will do to ensure there are no errors

```
$ terraform plan -var-file=workspace-variables/staging.tfvars
```

6. Apply Terraform changes
```
$ terraform apply -var-file=workspace-variables/staging.tfvars
```
