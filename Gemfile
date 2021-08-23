source "https://rubygems.org"

ruby "3.0.2"

RAILS_VERSION = "~> 6.1.4".freeze
gem "actionmailer", ">= 6.1.4.1", RAILS_VERSION
gem "actionpack", ">= 6.1.4.1", RAILS_VERSION
gem "activejob", RAILS_VERSION
gem "activemodel", RAILS_VERSION
gem "activerecord", RAILS_VERSION
gem "activestorage", ">= 6.1.4.1", RAILS_VERSION
gem "activesupport", RAILS_VERSION
gem "railties", ">= 6.1.4.1", RAILS_VERSION

gem "activerecord-session_store", ">= 2.0.0"
gem "addressable"
gem "algoliasearch-rails", "~> 1.25.0"
gem "array_enum"
gem "aws-sdk-s3", require: false
gem "breasal"
gem "browser"
gem "colorize"
gem "devise", ">= 4.8.0"
gem "factory_bot_rails", ">= 6.2.0"
gem "faker"
gem "friendly_id"
gem "geocoder"
gem "google-apis-drive_v3"
gem "google-apis-indexing_v3"
gem "google-cloud-bigquery"
gem "google_drive", require: false
gem "govuk-components", ">= 1.2.0"
gem "govuk_design_system_formbuilder", "~> 2.6.0"
gem "high_voltage"
gem "httparty"
gem "ipaddr"
gem "jbuilder"
gem "jquery-rails", ">= 4.4.0"
gem "kaminari"
gem "kramdown"
gem "lockbox"
gem "lograge", ">= 0.11.2"
gem "mail-notify", ">= 1.0.4"
gem "mimemagic"
gem "noticed", ">= 1.4.1"
gem "omniauth"
gem "omniauth_openid_connect"
gem "pg"
gem "puma"
gem "rack-attack"
gem "rack-cors"
gem "rails-html-sanitizer"
gem "recaptcha"
gem "redis"
gem "rollbar"
gem "sanitize"
gem "sidekiq"
gem "sidekiq-cron"
gem "skylight"
gem "slim-rails", ">= 3.3.0"
gem "validate_url"
gem "view_component", "~> 2.30.0"
gem "webpacker", ">= 5.4.0"
gem "wicked", ">= 1.3.4"
gem "xml-sitemap"

group :development do
  gem "aws-sdk-ssm"
  gem "launchy"
  gem "listen"
  gem "spring"
  gem "spring-watcher-listen"
  gem "web-console", ">= 4.1.0"
end

group :development, :test do
  gem "axe-core-api"
  gem "axe-core-capybara"
  gem "axe-core-rspec"
  gem "brakeman"
  gem "bullet"
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "dotenv-rails", ">= 2.7.6"
  gem "pry"
  gem "pry-byebug"
  gem "pry-rails"
  gem "rails-controller-testing", ">= 1.0.5"
  gem "rspec-rails", ">= 5.0.1"
  gem "rspec-sonarqube-formatter", require: false
  gem "rubocop-performance"
  gem "rubocop-rails"
  gem "rubocop-rspec"
  gem "slim_lint", require: false
end

group :test do
  gem "capybara"
  gem "rack_session_access"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "simplecov", "<= 0.17.1", require: false # Newer versions of simplecov are not compatible with Sonarqube
  gem "vcr"
  gem "webmock"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
