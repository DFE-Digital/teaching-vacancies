source "https://rubygems.org"

ruby "2.7.3"

RAILS_VERSION = "~> 6.1.3".freeze
gem "actionmailer", RAILS_VERSION
gem "actionpack", RAILS_VERSION
gem "activejob", RAILS_VERSION
gem "activemodel", RAILS_VERSION
gem "activerecord", RAILS_VERSION
gem "activesupport", RAILS_VERSION
gem "railties", RAILS_VERSION

gem "activerecord-session_store"
gem "addressable"
gem "algoliasearch-rails"
gem "array_enum"
gem "breasal"
gem "browser"
gem "colorize"
gem "devise"
gem "factory_bot_rails"
gem "faker"
gem "friendly_id"
gem "geocoder"
gem "google-apis-drive_v3"
gem "google-apis-indexing_v3"
gem "google-cloud-bigquery"
gem "google_drive", require: false
gem "govuk-components"
gem "govuk_design_system_formbuilder"
gem "high_voltage"
gem "httparty"
gem "ipaddr"
gem "jbuilder"
gem "jquery-rails"
gem "kaminari"
gem "kramdown"
gem "lograge"
gem "mail-notify"
gem "mimemagic"
gem "noticed"
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
gem "slim-rails"
gem "validate_url"
gem "view_component"
gem "webpacker"
gem "wicked"
gem "xml-sitemap"

group :development do
  gem "aws-sdk-ssm"
  gem "launchy"
  gem "listen"
  gem "spring"
  gem "spring-watcher-listen"
  gem "web-console"
end

group :development, :test do
  gem "axe-core-capybara"
  gem "axe-core-rspec"
  gem "brakeman"
  gem "bullet"
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "dotenv-rails"
  gem "pry"
  gem "pry-byebug"
  gem "pry-rails"
  gem "rails-controller-testing"
  gem "rspec-rails"
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
