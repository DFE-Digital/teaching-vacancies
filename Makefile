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

dev:
		$(eval env=dev)

staging:
		$(eval env=staging)

deploy-local-image:
		$(eval repository=dfedigital/teaching-vacancies)
		$(eval tag=dev-$(shell git rev-parse HEAD)-$(shell date '+%Y%m%d%H%M%S'))
		docker build -t $(repository):$(tag) .
		docker push $(repository):$(tag)
		cf7 target -o dfe-teacher-services -s teaching-vacancies-$(env)
		cf7 push -f paas/web/manifest-docker-$(env).yml --var IMAGE_NAME=$(repository):$(tag)
		cf7 push -f paas/worker/manifest-docker-$(env).yml --var IMAGE_NAME=$(repository):$(tag)
