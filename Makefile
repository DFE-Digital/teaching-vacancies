.DEFAULT_GOAL:=help
SHELL:=/bin/bash

repository=dfedigital/teaching-vacancies

##@ Query parameter store to display environment variables. Requires AWS credentials

.PHONY: print-env
print-env: ## make -s local print-env > .env
		$(if $(env), , $(error Usage: make <env> print-env))
		@bin/run-in-env -t /tvs/dev/app -y terraform/workspace-variables/$(env)_app_env.yml \
			$(local_override) -o env_stdout $(local_filter)

##@ Set environment and corresponding configuration

.PHONY: local
local: ## local # Same values as the deployed dev environment, adapted for local developmemt
		$(eval env=dev)
		$(eval local_override=-y terraform/workspace-variables/local_app_env.yml -y terraform/workspace-variables/my_app_env.yml)
		$(eval local_filter=| sed -e '/RAILS_ENV=/d' -e '/RACK_ENV=/d' -e '/ROLLBAR_ENV=/d')
		@bin/algolia-prefix > terraform/workspace-variables/my_app_env.yml

.PHONY: dev
dev: ## dev
		$(eval env=dev)
		$(eval var_file=dev)

.PHONY: review
review: ## review # Requires `pr=NNNN`
		$(if $(pr), , $(error Missing environment variable "pr"))
		$(eval env=review-pr-$(pr))
		$(eval export TF_VAR_environment=review-pr-$(pr))
		$(eval var_file=review)
		$(eval backend_config=-backend-config="workspace_key_prefix=review:")

.PHONY: staging
staging: ## staging
		$(eval env=staging)
		$(eval var_file=staging)

.PHONY: production
production: ## production # Requires `CONFIRM_PRODUCTION=true`
		$(if $(CONFIRM_PRODUCTION), , $(error Can only run with CONFIRM_PRODUCTION))
		$(eval env=production)
		$(eval var_file=production)

##@ Docker - build, tag, and push an image from local code. Requires Docker CLI

.PHONY: build-local-image
build-local-image: ## make build-local-image
		$(eval export DOCKER_BUILDKIT=1)
		$(eval branch=$(shell git rev-parse --abbrev-ref HEAD))
		$(eval tag=dev-$(shell git rev-parse HEAD)-$(shell date '+%Y%m%d%H%M%S'))
		docker build \
			--build-arg BUILDKIT_INLINE_CACHE=1 \
			--cache-from $(repository):builder-master \
			--cache-from $(repository):builder-$(branch) \
			--cache-from $(repository):master \
			--cache-from $(repository):$(branch) \
			--cache-from $(repository):$(tag) \
			--tag $(repository):$(branch) \
			--tag $(repository):$(tag) \
			--target production \
			.

.PHONY: push-local-image
push-local-image: build-local-image ## make push-local-image # Requires active Docker Hub session (`docker login`)
		docker push $(repository):$(branch)
		docker push $(repository):$(tag)

##@ Plan or apply changes to dev, review, staging, or production. Requires Terraform CLI

.PHONY: check-docker-tag
check-docker-tag:
		$(if $(tag), , $(error Missing environment variable "tag"))
		$(eval export TF_VAR_paas_app_docker_image=$(repository):$(tag))

.PHONY: init-terraform
init-terraform:
		$(if $(passcode), , $(error Missing environment variable "passcode"))
		$(eval export TF_VAR_paas_sso_passcode=$(passcode))
		terraform init -input=false $(backend_config) -reconfigure terraform/app
		terraform workspace select $(env) terraform/app || terraform workspace new $(env) terraform/app

.PHONY: deploy-plan
deploy-plan: init-terraform check-docker-tag ## make passcode=MyPasscode tag=dev-08406f04dd9eadb7df6fcda5213be880d7df37ed-20201022090714 <env> deploy-plan
		terraform plan -var-file terraform/workspace-variables/$(var_file).tfvars terraform/app

.PHONY: deploy
deploy: init-terraform check-docker-tag ## make passcode=MyPasscode tag=47fd1475376bbfa16a773693133569b794408995 <env> deploy
		terraform apply -input=false -var-file terraform/workspace-variables/$(var_file).tfvars -auto-approve terraform/app

.PHONY: review-destroy
review-destroy: init-terraform ## make CONFIRM_DESTROY=true passcode=MyPasscode pr=2086 review review-destroy
		$(if $(CONFIRM_DESTROY), , $(error Can only run with CONFIRM_DESTROY))
		terraform destroy -var-file terraform/workspace-variables/review.tfvars terraform/app
		terraform workspace select default terraform/app && terraform workspace delete $(env) terraform/app

##@ terraform/common code. Requires privileged IAM account to run

.PHONY: terraform-common-init
terraform-common-init:
		terraform init -reconfigure terraform/common
		terraform workspace select default terraform/common

.PHONY: terraform-common-plan
terraform-common-plan: terraform-common-init ## make terraform-common-plan
		terraform plan terraform/common

.PHONY: terraform-common-apply
terraform-common-apply: terraform-common-init ## make terraform-common-apply
		terraform apply terraform/common

##@ terraform/monitoring. Deploys grafana, prometheus monitoring on Gov.UK PaaS

.PHONY: terraform-monitoring-init
terraform-monitoring-init:
		$(if $(passcode), , $(error Missing environment variable "passcode"))
		$(eval export TF_VAR_paas_sso_passcode=$(passcode))
		rm -rf .terraform
		terraform init -upgrade=true -input=false -reconfigure terraform/monitoring

.PHONY: terraform-monitoring-plan
terraform-monitoring-plan: terraform-monitoring-init ## make terraform-monitoring-plan passcode=MyPasscode
		terraform plan -input=false terraform/monitoring

.PHONY: terraform-monitoring-apply
terraform-monitoring-apply: terraform-monitoring-init ## make terraform-monitoring-apply passcode=MyPasscode
		terraform apply -input=false -auto-approve terraform/monitoring

##@ Help

.PHONY: help
help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
