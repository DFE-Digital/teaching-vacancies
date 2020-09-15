repository=dfedigital/teaching-vacancies

.PHONY: build
build: ## Create a new image
		docker-compose build

.PHONY: build-production
build-production: ## build a image for deploying
		docker-compose -f docker-compose.yml -f docker-compose.deploy.yml build

.PHONY: createdb
createdb: ## Sets up a clean database
		docker-compose down -v
		docker-compose run --rm web bundle exec rake db:create db:environment:set db:schema:load

.PHONY: serve
serve: ## Run the service
		docker-compose up

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

.PHONY: build-builder-image
build-builder-image:
		$(eval export DOCKER_BUILDKIT=1)
		docker build \
			--build-arg BUILDKIT_INLINE_CACHE=1 \
			--cache-from $(repository):latest-build-cache \
			--tag $(repository):latest-build-cache \
			--target dev-build \
			.
		docker push $(repository):latest-build-cache

.PHONY: build-local-image
build-local-image:
		$(eval tag=dev-$(shell git rev-parse HEAD)-$(shell date '+%Y%m%d%H%M%S'))
		$(eval export DOCKER_BUILDKIT=1)
		docker build \
			--build-arg BUILDKIT_INLINE_CACHE=1 \
			--cache-from $(repository):latest-build-cache \
			--cache-from $(repository):latest-production-cache \
			--tag $(repository):latest-production-cache \
			--tag $(repository):$(tag) \
			--target production \
			.

		docker push $(repository):latest-production-cache
		docker push $(repository):$(tag)

.PHONY: deploy-local-image
deploy-local-image: build-local-image deploy

.PHONY: init-terraform
init-terraform:
		$(if $(passcode), , $(error Missing environment variable "passcode"))
		$(if $(tag), , $(error Missing environment variable "tag"))
		$(eval export TF_VAR_paas_sso_passcode=$(passcode))
		$(eval export TF_VAR_paas_app_docker_image=$(repository):$(tag))
		terraform init -input=false $(backend_config) terraform/app
		terraform workspace select $(env) terraform/app || terraform workspace new $(env) terraform/app

.PHONY: deploy
deploy: init-terraform
		terraform apply -input=false -var-file terraform/workspace-variables/$(var_file).tfvars -auto-approve terraform/app

.PHONY: deploy-plan
deploy-plan: init-terraform
		terraform plan -var-file terraform/workspace-variables/$(var_file).tfvars terraform/app

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
