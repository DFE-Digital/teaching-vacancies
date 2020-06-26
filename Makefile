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
