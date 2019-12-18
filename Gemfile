source 'https://rubygems.org'

ruby '2.6.5'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.2.4'

gem 'puma', '~> 4.3'
gem 'pg', '~> 1.1'
gem 'elasticsearch-model'
gem 'faraday_middleware-aws-signers-v4'
gem 'friendly_id'
gem 'figaro'
gem 'httparty'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'
gem 'jbuilder', '~> 2.9'
gem 'addressable'
gem 'sanitize', '~> 5.1'
gem 'lograge'
gem 'colorize'
gem 'ipaddr'
gem 'geocoder', github: 'dxw/geocoder', branch: 'add-os-name-support'
gem 'redis'
gem 'redis-objects'
gem 'skylight'

gem 'omniauth', '~> 1.9'
gem 'omniauth_openid_connect', '~> 0.3'

gem 'breasal', '~> 0.0.1'

gem 'haml-rails'
gem 'kaminari'
gem 'roadie-rails'
gem 'simple_form'
gem 'rails-html-sanitizer', '~> 1.3.0' # Must be above this version due to CVE-2018-3741

gem 'govuk_design_system_formbuilder'
gem 'gov_uk_date_fields'
gem 'validate_url', '~> 1.0.8'
gem 'xml-sitemap'

gem 'rollbar', '~> 2.22'

gem 'rubocop', '~> 0.77.0'
gem 'rubocop-rails_config', '~> 0.9.0'

gem 'activerecord-session_store'
gem 'public_activity'
gem 'high_voltage', '~> 3.1'
gem 'google_drive', require: false
gem 'google-api-client'
gem 'google-cloud-bigquery'
gem 'browser'
gem 'mail-notify'
gem 'array_enum'

gem 'sidekiq'

group :test, :development, :staging do
  gem 'faker'
  gem 'factory_bot_rails'
  gem 'rails-controller-testing', '~> 1.0'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'launchy'
end

group :development, :test do
  gem 'bullet'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails'
  gem 'elasticsearch-extensions'
  gem 'pry'
  gem 'rspec-rails'
  gem 'teaspoon-mocha'
  gem 'coffee-rails'
  gem 'timecop'
end

group :test do
  gem 'capybara', '~> 3.29'
  gem 'database_cleaner'
  gem 'fuubar'
  gem 'mock_redis'
  gem 'poltergeist'
  gem 'rspec-collection_matchers'
  gem 'webmock', '~> 3.7'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'rack_session_access'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
