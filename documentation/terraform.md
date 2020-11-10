# Terraform

## `terraform plan` via the Makefile

Dev
```
make passcode=MyPasscode tag=dev-08406f04dd9eadb7df6fcda5213be880d7df37ed-20201022090714 dev terraform-app-plan
```

Staging
```
make passcode=MyPasscode tag=47fd1475376bbfa16a773693133569b794408995 staging terraform-app-plan
```

Production
```
make passcode=MyPasscode CONFIRM_PRODUCTION=true tag=47fd1475376bbfa16a773693133569b794408995 production terraform-app-plan
```

Review app
```
make passcode=MyPasscode pr=2086 tag=review-pr-2086-e4c2c4afd991161f88808c907b4c66a30e5f3ef4-20201002203641 review terraform-app-plan
```

## `terraform plan` with Terraform CLI commands

The equivalent of the Makefile `dev terraform-app-plan` is:
```
cd terraform/app
terraform init
terraform workspace select dev
terraform plan -var="paas_sso_passcode=MyPasscode" -var="paas_app_docker_image=dfedigital/teaching-vacancies:dev-08406f04dd9eadb7df6fcda5213be880d7df37ed-20201022090714" -var-file ../workspace-variables/dev.tfvars
```

## Planning out to a file, and using `terraform show`

Occasionally we see `terraform plan` output like this

```
# module.paas.cloudfoundry_app.web_app will be updated in-place
  ~ resource "cloudfoundry_app" "web_app" {
        command                    = "bundle exec rake cf:on_first_instance db:migrate && rails s"
        disk_quota                 = 1024
        docker_image               = "dfedigital/teaching-vacancies:dev-08406f04dd9eadb7df6fcda5213be880d7df37ed-20201022090714"
        enable_ssh                 = true
      ~ environment                = (sensitive value)
```

How do we get visibility of what the `(sensitive value)` change will be?

In the `terraform/app` directory:

```
terraform plan -var="paas_sso_passcode=MyPasscode" -var="paas_app_docker_image=dfedigital/teaching-vacancies:dev-08406f04dd9eadb7df6fcda5213be880d7df37ed-20201022090714" -var-file ../workspace-variables/dev.tfvars -out dev.plan
```
Then we can use `terraform show` to render as JSON
```
terraform show -json dev.plan > dev.json
```
Using `jq`, we can query for the specific module and find the before and after changes
```
cat dev.json | jq '.resource_changes[] | select(.address=="module.paas.cloudfoundry_app.web_app") | .change.before.environment' > dev_web_app_before.json
cat dev.json | jq '.resource_changes[] | select(.address=="module.paas.cloudfoundry_app.web_app") | .change.after.environment' > dev_web_app_after.json
```

Then a simple diff will show the planned changes.
Here we see that it's the addition of a feature flag
```
"FEATURE_MULTI_SCHOOL_JOBS": "true",
```

## Remove review app

In usual conditions, the [`destroy.yml`](../.github/workflows/destroy.yml) workflow destroys the review app resources on PR close

We can use the Makefile to destroy a review app, by passing a `CONFIRM_DESTROY=true` plus changing the action to `review-destroy`:
```
make passcode=MyPasscode pr=2086 CONFIRM_DESTROY=true review review-destroy
```

If you need to force the deletion of a workspace, this is possible with 
```
terraform init -input=false -backend-config="workspace_key_prefix=review:" -reconfigure terraform/app
terraform workspace select default terraform/app
terraform workspace delete -force review-pr-2086 terraform/app
``` 

## Terraform plan as the GitHub Actions deploy user

Using the principle of least privilege, GitHub Actions uses a separate IAM account for Terraform
The `deploy` user is itself created through Terraform, in the [`terraform/common/iam.tf`](../terraform/common/iam.tf) file

### Deploy user Access key and Secret key

These are output by Terraform at the end of a `terraform apply` command, i.e. running `make terraform-common-apply` will output
Access Key ID, Secret access key for the `bigquery` and `deploy` users

### Configure AWS credentials file

In `~/.aws/credentials`, [create a named profile](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html) like

```
[deploy]
aws_access_key_id = AKIAkeyID
aws_secret_access_key = Bz7eGsecretkey
```

We note that in [`provider.tf`](../terraform/app/provider.tf), we do not specify a profile:

```
provider aws {
  region = var.region
}
```

Therefore as per [this Gruntwork blog](https://blog.gruntwork.io/authenticating-to-aws-with-the-credentials-file-d16c0fbcbf9e), we can first set the profile with an environment variable

```
export AWS_PROFILE=deploy
terraform init -input=false -backend-config="workspace_key_prefix=review:" terraform/app
terraform workspace select default terraform/app
terraform workspace delete review-pr-2310 terraform/app
```

When you've finished, unset the environment variable with
```
unset AWS_PROFILE
```
