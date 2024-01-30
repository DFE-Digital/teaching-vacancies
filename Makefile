.DEFAULT_GOAL		:=help
SHELL				:=/bin/bash
DOCKER_REPOSITORY	:=ghcr.io/dfe-digital/teaching-vacancies
LOCAL_BRANCH		:=$$(git rev-parse --abbrev-ref HEAD)
LOCAL_SHA			:=$$(git rev-parse HEAD)
LOCAL_TAG			:=dev-$(LOCAL_BRANCH)-$(LOCAL_SHA)

TERRAFILE_VERSION=0.8
ARM_TEMPLATE_TAG=1.1.6
RG_TAGS={"Product" : "Teaching vacancies"}
REGION=UK South
SERVICE_NAME=teaching-vacancies
SERVICE_SHORT=tv
DOCKER_REPOSITORY=ghcr.io/dfe-digital/teaching-vacancies

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

edit-app-secrets: install-fetch-config ## make dev edit-app-secrets
		$(if $(env), , $(error Usage: make <env> edit-app-secrets))
		bin/fetch_config.rb -s aws-ssm-parameter:/teaching-vacancies/$(env)/app/secrets \
			-f yaml -e -c \
			-d aws-ssm-parameter:/teaching-vacancies/$(env)/app/secrets

##@ Set environment and corresponding configuration

.PHONY: local
local: ## local # Same values as the deployed dev environment, adapted for local developmemt
		$(eval env=dev)
		$(eval local_override=-d file:terraform/workspace-variables/local_app_env.yml -d file:terraform/workspace-variables/my_app_env.yml)
		$(eval local_filter=| sed -e '/APP_ROLE=/d' -e '/RAILS_ENV=/d')

bin/terrafile: ## Install terrafile to manage terraform modules
	curl -sL https://github.com/coretech/terrafile/releases/download/v${TERRAFILE_VERSION}/terrafile_${TERRAFILE_VERSION}_$$(uname)_x86_64.tar.gz \
		| tar xz -C ./bin terrafile

.PHONY: review
review: test-cluster ## review # Requires `pr_id=NNNN`
		$(if $(pr_id), , $(error Missing environment variable "pr_id"))
		$(eval env=review-pr-$(pr_id))
		$(eval space=teaching-vacancies-review)
		$(eval export TF_VAR_environment=$(env))
		$(eval var_file=review)
		$(eval backend_config=-backend-config="key=review/$(env).tfstate")
		$(eval include global_config/review.sh)
		$(eval azure_namespace=$(shell jq '.namespace' terraform/workspace-variables/$(var_file).tfvars.json))

.PHONY: staging
staging: test-cluster ## staging
		$(eval env=staging)
		$(eval space=teaching-vacancies-staging)
		$(eval var_file=$(env))
		$(eval backend_config=-backend-config="key=$(env)/app.tfstate")
		$(eval include global_config/staging.sh)
		$(eval azure_namespace=$(shell jq '.namespace' terraform/workspace-variables/$(var_file).tfvars.json))

.PHONY: production
production: production-cluster ## production # Requires `CONFIRM_PRODUCTION=YES` to be present
		@if [[ "$(CONFIRM_PRODUCTION)" != YES ]]; then echo "Please enter "CONFIRM_PRODUCTION=YES" to run workflow"; exit 1; fi
		$(eval env=production)
		$(eval space=teaching-vacancies-production)
		$(eval var_file=$(env))
		$(eval backend_config=-backend-config="key=$(env)/app.tfstate")
		$(eval include global_config/production.sh)
		$(eval azure_namespace=$(shell jq '.namespace' terraform/workspace-variables/$(var_file).tfvars.json))

.PHONY: qa
qa: test-cluster ## qa
		$(eval env=qa)
		$(eval space=teaching-vacancies-dev)
		$(eval var_file=$(env))
		$(eval backend_config=-backend-config="key=$(env)/app.tfstate")
		$(eval include global_config/qa.sh)
		$(eval azure_namespace=$(shell jq '.namespace' terraform/workspace-variables/$(var_file).tfvars.json))

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

##@ Plan or apply changes to, review, staging or production. Requires Terraform CLI

.PHONY: check-terraform-variables
check-terraform-variables:
		$(if $(tag), , $(eval export tag=main))
		$(eval export TF_VAR_app_docker_image=$(DOCKER_REPOSITORY):$(tag))

ci:	## Run in automation environment
	$(eval export AUTO_APPROVE=-auto-approve)
	$(eval export SKIP_AZURE_LOGIN=true)

.PHONY: terraform-app-init
terraform-app-init: bin/terrafile set-azure-account
	./bin/terrafile -p terraform/app/vendor/modules -f terraform/workspace-variables/$(var_file)_Terrafile
	terraform -chdir=terraform/app init -upgrade -reconfigure -input=false $(backend_config)

	$(eval export TF_VAR_azure_resource_prefix=${AZURE_RESOURCE_PREFIX})
	$(eval export TF_VAR_config_short=${CONFIG_SHORT})
	$(eval export TF_VAR_service_name=${SERVICE_NAME})
	$(eval export TF_VAR_service_short=${SERVICE_SHORT})


.PHONY: terraform-app-plan
terraform-app-plan: terraform-app-init check-terraform-variables ## make passcode=MyPasscode tag=dev-08406f04dd9eadb7df6fcda5213be880d7df37ed-20201022090714 <env> terraform-app-plan
		terraform -chdir=terraform/app plan -var-file ../workspace-variables/$(var_file).tfvars.json

.PHONY: terraform-app-apply
terraform-app-apply: terraform-app-init check-terraform-variables ## make passcode=MyPasscode tag=47fd1475376bbfa16a773693133569b794408995 <env> terraform-app-apply
		terraform -chdir=terraform/app apply -input=false -var-file ../workspace-variables/$(var_file).tfvars.json -auto-approve

terraform-app-destroy: terraform-app-init ## make qa destroy passcode=MyPasscode
	terraform -chdir=terraform/app destroy -var-file ../workspace-variables/${var_file}.tfvars.json ${AUTO_APPROVE}

##@ terraform/common code. Requires privileged IAM account to run

.PHONY: terraform-common-init
terraform-common-init:
		terraform -chdir=terraform/common init -upgrade -reconfigure -input=false

.PHONY: terraform-common-plan
terraform-common-plan: terraform-common-init ## make terraform-common-plan
		terraform -chdir=terraform/common plan

.PHONY: terraform-common-apply
terraform-common-apply: terraform-common-init ## make terraform-common-apply
		terraform -chdir=terraform/common apply

##@ install konduit
bin/konduit.sh:
	curl -s https://raw.githubusercontent.com/DFE-Digital/teacher-services-cloud/main/scripts/konduit.sh -o bin/konduit.sh \
		&& chmod +x bin/konduit.sh

##@ rails console. Ability to rail console to apps on AKS

composed-variables:
	$(eval RESOURCE_GROUP_NAME=${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-rg)
	$(eval STORAGE_ACCOUNT_NAME=${AZURE_RESOURCE_PREFIX}${SERVICE_SHORT}tfstate${CONFIG_SHORT}sa)
	$(eval KEYVAULT_NAMES='("${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-app-kv", "${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-inf-kv")')

set-what-if:
	$(eval WHAT_IF=--what-if)

arm-deployment: composed-variables set-azure-account
	$(if ${DISABLE_KEYVAULTS},, $(eval KV_ARG=keyVaultNames=${KEYVAULT_NAMES}))

	az deployment sub create --name "resourcedeploy-tsc-$(shell date +%Y%m%d%H%M%S)" \
		-l "${REGION}" --template-uri "https://raw.githubusercontent.com/DFE-Digital/tra-shared-services/${ARM_TEMPLATE_TAG}/azure/resourcedeploy.json" \
		--parameters "resourceGroupName=${RESOURCE_GROUP_NAME}" 'tags=${RG_TAGS}' \
		"tfStorageAccountName=${STORAGE_ACCOUNT_NAME}" "tfStorageContainerName=terraform-state" \
		${KV_ARG} \
		"enableKVPurgeProtection=${KV_PURGE_PROTECTION}" \
		${WHAT_IF}

deploy-arm-resources: arm-deployment

validate-arm-resources: set-what-if arm-deployment

##@ Azure AKS cluster commands

set-azure-account:
	[ "${SKIP_AZURE_LOGIN}" != "true" ] && az account set -s ${AZURE_SUBSCRIPTION} || true

production-cluster:
	$(eval CLUSTER_RESOURCE_GROUP_NAME=s189p01-tsc-pd-rg)
	$(eval CLUSTER_NAME=s189p01-tsc-production-aks)

test-cluster:
	$(eval CLUSTER_RESOURCE_GROUP_NAME=s189t01-tsc-ts-rg)
	$(eval CLUSTER_NAME=s189t01-tsc-test-aks)

get-cluster-credentials: set-azure-account
	$(if $(env), , $(error Missing <env>. Usage: "make <env> get-cluster-credentials"))
	az aks get-credentials --overwrite-existing -g ${CLUSTER_RESOURCE_GROUP_NAME} -n ${CLUSTER_NAME}
	kubelogin convert-kubeconfig -l $(if ${GITHUB_ACTIONS},spn,azurecli)

# make review pr_id=5432 shell
# make qa shell
.PHONY: shell
shell: get-cluster-credentials
	$(if $(env), , $(error Missing <env>. Usage: "make <env> shell"))
	kubectl -n $(azure_namespace) exec -ti deployment/teaching-vacancies-$(env) -- sh

# make review pr_id=5432 railsc
# make qa railsc
.PHONY: railsc
railsc: get-cluster-credentials
	$(if $(env), , $(error Missing <env>. Usage: "make <env> railsc"))
	kubectl -n $(azure_namespace) exec -ti deployment/teaching-vacancies-$(env) -- rails c

# make qa rake task=audit:email_addresses
# make review pr_id=5432 rake task=audit:email_addresses
.PHONY: rake
rake: get-cluster-credentials
	$(if $(env), , $(error Missing <env>. Usage: "make <env> rake task=<namespace:task>"))
	$(if $(task), , $(error Missing <task>. Usage: "make <env> rake task=<namespace:task>"))
	kubectl -n $(azure_namespace) exec -ti deployment/teaching-vacancies-$(env) -- bundle exec rake $(task)

# make qa logs
# make review pr_id=5432 logs
.PHONY: logs
logs: get-cluster-credentials
	$(if $(env), , $(error Missing <env>. Usage: "make <env> logs"))
	kubectl -n $(azure_namespace) logs -f deployment/teaching-vacancies-$(env)

##@ Help

.PHONY: help
help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
