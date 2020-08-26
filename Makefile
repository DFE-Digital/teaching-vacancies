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

.PHONY: review
review:
		$(eval env=review)

.PHONY: staging
staging:
		$(eval env=staging)

.PHONY: build-local-image
build-local-image:
		$(eval tag=dev-$(shell git rev-parse HEAD)-$(shell date '+%Y%m%d%H%M%S'))
		docker build -t $(repository):$(tag) .
		docker push $(repository):$(tag)

.PHONY: deploy-local-image
deploy-local-image: build-local-image deploy

.PHONY: init-terraform
init-terraform:
		$(if $(passcode), , $(error Missing environment variable "passcode"))
		$(if $(tag), , $(error Missing environment variable "tag"))
		$(eval export TF_VAR_paas_sso_passcode=$(passcode))
		$(eval export TF_VAR_paas_app_docker_image=$(repository):$(tag))
		$(eval export TF_WORKSPACE=$(env))
		terraform init -input=false terraform/app

.PHONY: init-terraform-review
init-terraform-review:
		$(if $(passcode), , $(error Missing environment variable "passcode"))
		$(if $(tag), , $(error Missing environment variable "tag"))
		$(if $(prnum), , $(error Missing environment variable "prnum"))
		$(eval export TF_VAR_paas_sso_passcode=$(passcode))
		$(eval export TF_VAR_paas_app_docker_image=$(repository):$(tag))
		$(eval export TF_WORKSPACE=$(prnum))
		terraform init -backend-config="workspace_key_prefix=env/review" terraform/app
		terraform plan -var-file terraform/workspace-variables/$(env).tfvars terraform/app

.PHONY: deploy
deploy: init-terraform
		terraform apply -input=false -var-file terraform/workspace-variables/$(env).tfvars -auto-approve terraform/app

.PHONY: deploy-plan
deploy-plan: init-terraform
		terraform plan -var-file terraform/workspace-variables/$(env).tfvars terraform/app

.PHONY: print-env
print-env:
		$(if $(env), , $(error Usage: make <env> print-env))
		@bin/run-in-env -t /tvs/dev/app -y terraform/workspace-variables/$(env)_app_env.yml -o env_stdout
