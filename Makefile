.DEFAULT_GOAL		:=help
SHELL				:=/bin/bash
DOCKER_REPOSITORY	:=ghcr.io/dfe-digital/teaching-vacancies
LOCAL_BRANCH		:=$$(git rev-parse --abbrev-ref HEAD)
LOCAL_SHA			:=$$(git rev-parse HEAD)
LOCAL_TAG			:=dev-$(LOCAL_BRANCH)-$(LOCAL_SHA)

##@ Query parameter store to display environment variables. Requires AWS credentials

.PHONY: install-fetch-config
install-fetch-config:
	[ ! -f bin/fetch_config.rb ] \
		&& curl -s https://raw.githubusercontent.com/DFE-Digital/bat-platform-building-blocks/master/scripts/fetch_config/fetch_config.rb -o bin/fetch_config.rb \
		&& chmod +x bin/fetch_config.rb \
		|| true

.PHONY: print-env
print-env: install-fetch-config ## make -s local print-env > .env
		$(if $(env), , $(error Usage: make <env> print-env))
		@bin/fetch_config.rb -s aws-ssm-parameter-path:/teaching-vacancies/$(env)/app \
			-s yaml-file:terraform/workspace-variables/$(env)_app_env.yml \
			-f shell-env-var \
			$(local_override) -d stdout $(local_filter)

##@ Set environment and corresponding configuration

.PHONY: local
local: ## local # Same values as the deployed dev environment, adapted for local developmemt
		$(eval env=dev)
		$(eval local_override=-d file:terraform/workspace-variables/local_app_env.yml -d file:terraform/workspace-variables/my_app_env.yml)
		$(eval local_filter=| sed -e '/APP_ROLE=/d' -e '/RAILS_ENV=/d' -e '/ROLLBAR_ENV=/d')
		@bin/algolia-prefix > terraform/workspace-variables/my_app_env.yml

.PHONY: dev
dev: ## dev
		$(eval env=dev)
		$(eval space=teaching-vacancies-dev)
		$(eval var_file=$(env))
		$(eval backend_config=-backend-config="key=$(env)/app.tfstate")

.PHONY: review
review: ## review # Requires `pr_id=NNNN`
		$(if $(pr_id), , $(error Missing environment variable "pr_id"))
		$(eval env=review-pr-$(pr_id))
		$(eval space=teaching-vacancies-review)
		$(eval export TF_VAR_environment=$(env))
		$(eval var_file=review)
		$(eval backend_config=-backend-config="key=review/$(env).tfstate")

.PHONY: staging
staging: ## staging
		$(eval env=staging)
		$(eval space=teaching-vacancies-staging)
		$(eval var_file=$(env))
		$(eval backend_config=-backend-config="key=$(env)/app.tfstate")

.PHONY: production
production: ## production # Requires `CONFIRM_PRODUCTION=true`
		$(if $(CONFIRM_PRODUCTION), , $(error Can only run with CONFIRM_PRODUCTION))
		$(eval env=production)
		$(eval space=teaching-vacancies-production)
		$(eval var_file=$(env))
		$(eval backend_config=-backend-config="key=$(env)/app.tfstate")

.PHONY: qa
qa: ## qa
		$(eval env=qa)
		$(eval space=teaching-vacancies-dev)
		$(eval var_file=$(env))
		$(eval backend_config=-backend-config="key=$(env)/app.tfstate")

research: ## research
		$(eval env=research)
		$(eval space=teaching-vacancies-dev)
		$(eval var_file=$(env))
		$(eval backend_config=-backend-config="key=dev/app-$(env).tfstate")

##@ Docker - build, tag, and push an image from local code. Requires Docker CLI

.PHONY: build-local-image
build-local-image: ## make build-local-image
		$(eval export DOCKER_BUILDKIT=1)
		docker build \
			--build-arg BUILDKIT_INLINE_CACHE=1 \
			--cache-from $(DOCKER_REPOSITORY):builder-master \
			--cache-from $(DOCKER_REPOSITORY):builder-$(LOCAL_BRANCH) \
			--cache-from $(DOCKER_REPOSITORY):master \
			--cache-from $(DOCKER_REPOSITORY):$(LOCAL_BRANCH) \
			--cache-from $(DOCKER_REPOSITORY):$(LOCAL_TAG) \
			--tag $(DOCKER_REPOSITORY):$(LOCAL_BRANCH) \
			--tag $(DOCKER_REPOSITORY):$(LOCAL_TAG) \
			--target production \
			.

.PHONY: push-local-image
push-local-image: build-local-image ## make push-local-image # Requires active Docker Hub session (`docker login`)
		docker push $(DOCKER_REPOSITORY):$(LOCAL_BRANCH)
		docker push $(DOCKER_REPOSITORY):$(LOCAL_TAG)
		$(eval tag=$(LOCAL_TAG))

.PHONY: plan-local-image
plan-local-image: push-local-image terraform-app-plan## make passcode=MyPasscode <env> plan-local-image # Requires active Docker Hub session (`docker login`)

.PHONY: deploy-local-image
deploy-local-image: push-local-image terraform-app-plan## make passcode=MyPasscode <env> deploy-local-image # Requires active Docker Hub session (`docker login`)

##@ Plan or apply changes to dev, review, staging, or production. Requires Terraform CLI

.PHONY: check-terraform-variables
check-terraform-variables:
		$(if $(tag), , $(eval export tag=master))
		$(eval export TF_VAR_paas_app_docker_image=$(DOCKER_REPOSITORY):$(tag))
		$(if $(or $(disable_passcode),$(passcode)), , $(error Missing environment variable "passcode", retrieve from https://login.london.cloud.service.gov.uk/passcode))
		$(eval export TF_VAR_paas_sso_passcode=$(passcode))

ci:	## Run in automation environment
	$(eval export disable_passcode=true)
	$(eval export AUTO_APPROVE=-auto-approve)

.PHONY: terraform-app-init
terraform-app-init:
		cd terraform/app && rm -f .terraform.lock.hcl && terraform init -reconfigure -input=false $(backend_config)

.PHONY: terraform-app-plan
terraform-app-plan: terraform-app-init check-terraform-variables ## make passcode=MyPasscode tag=dev-08406f04dd9eadb7df6fcda5213be880d7df37ed-20201022090714 <env> terraform-app-plan
		cd terraform/app && terraform plan -var-file ../workspace-variables/$(var_file).tfvars

.PHONY: terraform-app-apply
terraform-app-apply: terraform-app-init check-terraform-variables ## make passcode=MyPasscode tag=47fd1475376bbfa16a773693133569b794408995 <env> terraform-app-apply
		cd terraform/app && terraform apply -input=false -var-file ../workspace-variables/$(var_file).tfvars -auto-approve

terraform-app-destroy: terraform-app-init ## make qa destroy passcode=MyPasscode
	$(if $(CONFIRM_DESTROY), , $(error Can only run with CONFIRM_DESTROY))
	cd terraform/app && terraform destroy -var-file ../workspace-variables/${var_file}.tfvars

terraform-app-database-replace: terraform-app-init check-terraform-variables
	$(if $(CONFIRM_REPLACE), , $(error Can only run with CONFIRM_REPLACE)) \
	cd terraform/app && terraform apply \
		-replace="module.paas.cloudfoundry_service_instance.postgres_instance" \
		-replace="module.paas.cloudfoundry_app.web_app" \
		-replace="module.paas.cloudfoundry_app.worker_app" \
		-var-file ../workspace-variables/${var_file}.tfvars -auto-approve

##@ terraform/common code. Requires privileged IAM account to run

.PHONY: terraform-common-init
terraform-common-init:
		cd terraform/common && rm -f .terraform.lock.hcl && terraform init -reconfigure -input=false

.PHONY: terraform-common-plan
terraform-common-plan: terraform-common-init ## make terraform-common-plan
		cd terraform/common && terraform plan

.PHONY: terraform-common-apply
terraform-common-apply: terraform-common-init ## make terraform-common-apply
		cd terraform/common && terraform apply

##@ terraform/monitoring. Deploys grafana, prometheus monitoring on Gov.UK PaaS

.PHONY: terraform-monitoring-init
terraform-monitoring-init:
		$(if $(passcode), , $(error Missing environment variable "passcode"))
		$(eval export TF_VAR_paas_sso_passcode=$(passcode))
		cd terraform/monitoring && rm -f .terraform.lock.hcl && terraform init -upgrade=true -reconfigure -input=false

.PHONY: terraform-monitoring-plan
terraform-monitoring-plan: terraform-monitoring-init ## make passcode=MyPasscode terraform-monitoring-plan
		cd terraform/monitoring && terraform plan -input=false

.PHONY: terraform-monitoring-apply
terraform-monitoring-apply: terraform-monitoring-init ## make passcode=MyPasscode terraform-monitoring-apply
		cd terraform/monitoring && terraform apply -input=false -auto-approve

##@ rails console. Ability to rail console to apps on PaaS

console: ## make qa console
	cf target -s ${space}
	cf ssh teaching-vacancies-${env} -t -c "cd /app && /usr/local/bin/bundle exec rails c"

get-postgres-instance-guid: ## Gets the postgres service instance's guid make dev passcode=xxxxx get-postgres-instance-guid
	cf target -s ${space} 1> /dev/null
	$(eval export DB_INSTANCE_GUID=$(shell cf service teaching-vacancies-postgres-${env} --guid))
	@echo The guid for the database is: ${DB_INSTANCE_GUID}

rename-postgres-service: ## make dev rename-postgres-service
	cf target -s ${space} 1> /dev/null
	cf rename-service teaching-vacancies-postgres-${env} teaching-vacancies-postgres-${env}-old

remove-postgres-tf-state: terraform-app-init ## make dev remove-postgres-tf-state
	cd terraform/app && terraform state rm module.paas.cloudfoundry_service_instance.postgres_instance

restore-postgres: set-restore-variables terraform-app-apply ##  make dev DB_INSTANCE_GUID=abcdb262-79d1-xx1x-b1dc-0534fb9b4 SNAPSHOT_TIME="2021-11-16 15:20:00" passcode=xxxxx restore-postgres

set-restore-variables:
	$(if $(DB_INSTANCE_GUID), , $(error can only run with DB_INSTANCE_GUID, get it by running `make ${space} get-postgres-instance-guid`))
	$(if $(SNAPSHOT_TIME), , $(error can only run with BEFORE_TIME, eg SNAPSHOT_TIME="2021-09-14 16:00:00"))
	$(eval export TF_VAR_paas_restore_from_db_guid=$(DB_INSTANCE_GUID))
	$(eval export TF_VAR_paas_db_backup_before_point_in_time=$(SNAPSHOT_TIME))
	echo "Restoring teaching-vacancies from $(TF_VAR_paas_restore_from_db_guid) before $(TF_VAR_paas_db_backup_before_point_in_time)"


##@ Help

.PHONY: help
help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
