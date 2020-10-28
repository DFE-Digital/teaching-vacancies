source 'https://rubygems.org'

ruby '2.7.2'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 6.0'

gem 'activerecord-session_store'
gem 'addressable'
gem 'algoliasearch-rails'
gem 'array_enum'
gem 'breasal'
gem 'browser'
gem 'colorize'
gem 'factory_bot_rails'
gem 'faker'
gem 'figaro'
gem 'friendly_id'
gem 'geocoder'
gem 'google-api-client'
gem 'google-cloud-bigquery'
gem 'google_drive', require: false
gem 'gov_uk_date_fields'
gem 'govuk_design_system_formbuilder'
gem 'haml-rails'
gem 'high_voltage'
gem 'httparty'
gem 'ipaddr'
gem 'jbuilder'
gem 'jquery-rails'
gem 'kaminari'
gem 'kramdown'
gem 'lograge'
gem 'mail-notify'
gem 'omniauth'
gem 'omniauth_openid_connect'
gem 'pg'
gem 'public_activity'
gem 'puma'
gem 'rack-cors'
gem 'rails-html-sanitizer'
gem 'recaptcha'
gem 'redis'
gem 'redis-objects'
gem 'rollbar'
gem 'sanitize'
gem 'sidekiq'
gem 'sidekiq-cron'
gem 'skylight'
gem 'validate_url'
gem 'view_component'
gem 'webpacker'
gem 'xml-sitemap'

group :development do
  gem 'aws-sdk-ssm'
  gem 'launchy'
  gem 'listen'
  gem 'spring'
  gem 'spring-watcher-listen'
  gem 'web-console'
end

group :development, :test do
  gem 'bullet'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'rspec-sonarqube-formatter', require: false
  gem 'rubocop-govuk'
end

group :test do
  gem 'capybara'
  gem 'mock_redis'
  gem 'rack_session_access'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'simplecov', '<= 0.17.1', require: false # Newer versions of simplecov are not compatible with Sonarqube
  gem 'webmock'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
