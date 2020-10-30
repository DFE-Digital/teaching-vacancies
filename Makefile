repository=dfedigital/teaching-vacancies

monitoring-plan: ## Validate monitoring changes
		TF_WORKSPACE=monitoring terraform init -upgrade=true -input=false terraform/monitoring \
		&& bin/run-in-env -e monitoring -o tf_subshell -- terraform plan -input=false terraform/monitoring

monitoring-apply: ## Apply monitoring changes
		TF_WORKSPACE=monitoring terraform init -upgrade=true -input=false terraform/monitoring \
		&& bin/run-in-env -e monitoring -o tf_subshell -- terraform apply -input=false -auto-approve terraform/monitoring

.PHONY: dev
dev:
		$(eval env=dev)
		$(eval var_file=dev)

.PHONY: review
review:
		$(if $(pr), , $(error Missing environment variable "pr"))
		$(eval env=review-pr-$(pr))
		$(eval export TF_VAR_environment=review-pr-$(pr))
		$(eval var_file=review)
		$(eval backend_config=-backend-config="workspace_key_prefix=review:")

.PHONY: staging
staging:
		$(eval env=staging)
		$(eval var_file=staging)

.PHONY: production
production:
		$(if $(CONFIRM_PRODUCTION), , $(error Can only run with CONFIRM_PRODUCTION))
		$(eval env=production)
		$(eval var_file=production)

.PHONY: check-docker-tag
check-docker-tag:
		$(if $(tag), , $(error Missing environment variable "tag"))
		$(eval export TF_VAR_paas_app_docker_image=$(repository):$(tag))

.PHONY: build-local-image
build-local-image:
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

		docker push $(repository):$(branch)
		docker push $(repository):$(tag)

.PHONY: deploy-local-image
deploy-local-image: build-local-image deploy

.PHONY: init-terraform
init-terraform:
		$(if $(passcode), , $(error Missing environment variable "passcode"))
		$(eval export TF_VAR_paas_sso_passcode=$(passcode))
		terraform init -input=false $(backend_config) terraform/app
		terraform workspace select $(env) terraform/app || terraform workspace new $(env) terraform/app

.PHONY: deploy
deploy: init-terraform check-docker-tag
		terraform apply -input=false -var-file terraform/workspace-variables/$(var_file).tfvars -auto-approve terraform/app

.PHONY: deploy-plan
deploy-plan: init-terraform check-docker-tag
		terraform plan -var-file terraform/workspace-variables/$(var_file).tfvars terraform/app

.PHONY: review-destroy
review-destroy: init-terraform
		$(if $(CONFIRM_DESTROY), , $(error Can only run with CONFIRM_DESTROY))
		terraform plan -var-file terraform/workspace-variables/review.tfvars -destroy -out=destroy-$(env).plan terraform/app
		terraform apply "destroy-$(env).plan"

.PHONY: print-env
print-env:
		$(if $(env), , $(error Usage: make <env> print-env))
		@bin/run-in-env -t /tvs/dev/app -y terraform/workspace-variables/$(env)_app_env.yml -o env_stdout

terraform-common-init:
		terraform init terraform/common

terraform-common-plan: terraform-common-init
		terraform plan terraform/common

terraform-common-apply: terraform-common-init
		terraform apply terraform/common
