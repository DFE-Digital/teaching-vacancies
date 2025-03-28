# Terraform

## `terraform plan` via the Makefile
In order to run the command you first have to login via ```az login``` (or ```az login --use-device-code``` to authenticate in a non-default browser)

You will then need to assume the `Deployments` role. If you are using
[aws-vault](/documentation/operations/infrastructure/aws-roles-and-cli-tools.md), this is as easy as running the make command through
`aws-vault exec`:

```
aws-vault exec Deployments -- [make invocation from below]
```

Production
```
make CONFIRM_PRODUCTION=true tag=47fd1475376bbfa16a773693133569b794408995 production terraform-app-plan
```

QA
```
make tag=dev-08406f04dd9eadb7df6fcda5213be880d7df37ed-20201022090714 qa terraform-app-plan
```

Review app
```
make pr_id=2086 tag=review-pr-2086-e4c2c4afd991161f88808c907b4c66a30e5f3ef4-20201002203641 review terraform-app-plan
```

Staging
```
make tag=47fd1475376bbfa16a773693133569b794408995 staging terraform-app-plan
```

To run the commands below, you will first need to assume the `Administrator` role with [aws-vault](/documentation/operations/infrastructure/aws-roles-and-cli-tools.md)

Common
```
make terraform-common-plan
```

## Cleaning up after review apps that failed to destroy on PR close

Occasionally, some issue will prevent a review app and its associated worker and services from
getting destroyed. To clean up manually, use the `terraform-app-destroy` make target and set the
`pr_id` variable to the PR ID from Github:

```
make pr_id=1234 review terraform-app-destroy
```

## Planning out to a file, and using `terraform show`

Occasionally we see `terraform plan` output like this

```
# module.paas.cloudfoundry_app.web_app will be updated in-place
  ~ resource "cloudfoundry_app" "web_app" {
        command                    = "bundle exec rake db:migrate:ignore_concurrent_migration_exceptions && rails s"
        disk_quota                 = 1024
        docker_image               = "dfedigital/teaching-vacancies:dev-08406f04dd9eadb7df6fcda5213be880d7df37ed-20201022090714"
        enable_ssh                 = true
      ~ environment                = (sensitive value)
```

How do we get visibility of what the `(sensitive value)` change will be?

In the `terraform/app` directory:

```
terraform plan  -var="app_docker_image=dfedigital/teaching-vacancies:dev-08406f04dd9eadb7df6fcda5213be880d7df37ed-20201022090714" -var-file ../workspace-variables/dev.tfvars.json -out dev.plan
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

## GitHub Actions deploy user

Using the principle of least privilege, GitHub Actions uses a separate IAM account for Terraform
The `deploy` user is itself created through Terraform, in the [terraform/common/iam.tf](../terraform/common/iam.tf) file

### Deploy user Access key and Secret key

These are output by Terraform at the end of a `terraform apply` command, i.e. running `make terraform-common-apply` will output
Access Key ID, Secret access key for the `deploy` user, and then used by GitHub Actions workflows to assume the `Deployments` role.
