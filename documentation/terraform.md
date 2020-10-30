# Terraform

## `terraform plan` via the Makefile

Dev
```
make passcode=MyPasscode tag=dev-08406f04dd9eadb7df6fcda5213be880d7df37ed-20201022090714 dev deploy-plan
```

Staging
```
make passcode=MyPasscode tag=47fd1475376bbfa16a773693133569b794408995 staging deploy-plan
```

Production
```
make CONFIRM_PRODUCTION=true passcode=MyPasscode tag=47fd1475376bbfa16a773693133569b794408995 production deploy-plan
```

Review app
```
make pr=2086 passcode=MyPasscode tag=review-pr-2086-e4c2c4afd991161f88808c907b4c66a30e5f3ef4-20201002203641 review deploy-plan
```

## `terraform plan` with Terraform CLI commands

The equivalent of the Makefile `dev deploy-plan` is:
```
terraform init terraform/app
terraform workspace select dev
terraform plan -var="paas_sso_passcode=MyPasscode" -var="paas_app_docker_image=dev-08406f04dd9eadb7df6fcda5213be880d7df37ed-20201022090714" -var-file terraform/workspace-variables/dev.tfvars terraform/app
```

If we need to pass options to the Terraform CLI, we can work directly in the `terraform/app` directory itself:

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

In usual conditions, the [`destroy.yml`](.github/workflows/destroy.yml) workflow destroys the review app resources on PR close

We can use the Makefile to destroy a review app, by passing a `CONFIRM_DESTROY=true` plus changing the action to `review-destroy`:
```
make pr=2086 CONFIRM_DESTROY=true passcode=MyPasscode review review-destroy
```
