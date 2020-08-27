source 'https://rubygems.org'

ruby '2.6.6'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.2.4'

gem 'activerecord-session_store'
gem 'addressable'
gem 'algoliasearch-rails'
gem 'array_enum'
gem 'breasal', '~> 0.0.1'
gem 'browser'
gem 'colorize'
gem 'figaro'
gem 'friendly_id'
gem 'geocoder'
gem 'google-api-client'
gem 'google-cloud-bigquery'
gem 'google-cloud-storage'
gem 'google_drive', require: false
gem 'gov_uk_date_fields'
gem 'govuk_design_system_formbuilder', '~> 1.2.6'
gem 'haml-rails'
gem 'high_voltage', '~> 3.1'
gem 'httparty'
gem 'ipaddr'
gem 'jbuilder', '~> 2.9'
gem 'jquery-rails'
gem 'kaminari'
gem 'kramdown'
gem 'lograge'
gem 'mail-notify'
gem 'omniauth', '~> 1.9'
gem 'omniauth_openid_connect', '~> 0.3'
gem 'pg', '~> 1.1'
gem 'public_activity'
gem 'puma', '~> 4.3'
gem 'rack-cors'
gem 'rails-html-sanitizer', '~> 1.3.0' # Must be above this version due to CVE-2018-3741
gem 'recaptcha'
gem 'redis'
gem 'redis-objects'
gem 'rollbar', '~> 2.22'
gem 'sanitize', '~> 5.2'
gem 'sidekiq'
gem 'sidekiq-cron', '~> 1.1'
gem 'skylight'
gem 'validate_url', '~> 1.0.8'
gem 'view_component'
gem 'webpacker'
gem 'xml-sitemap'

group :development do
  gem 'aws-sdk-ssm', '~> 1.83.0'
  gem 'launchy'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

group :development, :test do
  gem 'bullet'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rails-controller-testing', '~> 1.0'
  gem 'rspec-rails'
  gem 'rubocop', '~> 0.77.0'
  gem 'rubocop-rails_config', '~> 0.9.0'
end

group :test do
  gem 'capybara', '~> 3.33'
  gem 'database_cleaner'
  gem 'fuubar'
  gem 'mock_redis'
  gem 'rack_session_access'
  gem 'selenium-webdriver', '~> 3.142'
  gem 'shoulda-matchers'
  gem 'webmock', '~> 3.7'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
