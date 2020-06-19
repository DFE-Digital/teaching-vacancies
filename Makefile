.PHONY: build
build: ## Create a new image
		docker-compose build

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
