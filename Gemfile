source "https://rubygems.org"

ruby "3.1.2"

RAILS_VERSION = "~> 7.0.3".freeze
gem "actionmailer", RAILS_VERSION
gem "actionpack", RAILS_VERSION
gem "activejob", RAILS_VERSION
gem "activemodel", RAILS_VERSION
gem "activerecord", RAILS_VERSION
gem "activestorage", RAILS_VERSION
gem "activesupport", RAILS_VERSION
gem "railties", RAILS_VERSION

gem "propshaft"

gem "activerecord-import"
gem "activerecord-postgis-adapter"
gem "activerecord-session_store"
gem "addressable"
gem "array_enum"
gem "aws-sdk-s3", require: false
gem "breasal"
gem "devise"
gem "factory_bot_rails"
gem "faker"
gem "friendly_id"
gem "front_matter_parser"
gem "geocoder"
gem "google-apis-drive_v3"
gem "google-apis-indexing_v3"
gem "google-cloud-bigquery"
gem "govuk-components", "3.0.4" # TODO: Pinned pending fixes for incompatible 3.0.6
gem "govuk_design_system_formbuilder"
gem "high_voltage"
gem "httparty"
gem "ipaddr"
gem "jbuilder"
gem "kaminari"
gem "kramdown"
gem "lockbox"
gem "mail-notify"
gem "mimemagic"
gem "nokogiri"
gem "noticed"
gem "omniauth", "< 2" # TODO: Pinned pending fixes
gem "omniauth_openid_connect", "< 0.4" # TODO: Pinned pending fixes
gem "paper_trail"
gem "paper_trail-globalid"
gem "parslet"
gem "pg"
gem "puma"
gem "rack-attack"
gem "rack-cors"
gem "rails_semantic_logger"
gem "recaptcha"
gem "redis"
gem "rgeo-geojson"
gem "sanitize"
gem "sentry-rails"
gem "sentry-ruby"
gem "sentry-sidekiq"
gem "sidekiq"
gem "sidekiq-cron"
gem "skylight"
gem "slim-rails"
gem "validate_url"
gem "view_component"
gem "webpacker"
gem "wicked"
gem "xml-sitemap"
gem "zendesk_api"

group :development do
  gem "amazing_print" # optional dependency of `rails_semantic_logger`
  gem "aws-sdk-ssm"
  gem "listen"
  gem "solargraph", require: false
  gem "spring"
  gem "spring-commands-rspec"
  # TODO: Pinned until Spring >= 3 compatible version released
  gem "spring-watcher-listen", github: "rails/spring-watcher-listen"
  gem "web-console"
end

group :development, :test do
  gem "axe-core-api"
  gem "axe-core-capybara"
  gem "axe-core-rspec"
  gem "brakeman"
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "dotenv-rails"
  gem "pry"
  gem "pry-byebug"
  gem "pry-rails"
  gem "rack-mini-profiler", require: false
  gem "rails-controller-testing"
  gem "rspec-rails", ">= 6.0.0rc" # TODO: Unpin when 6.0 final is out
  gem "rubocop-performance"
  gem "rubocop-rails"
  gem "rubocop-rspec"
  gem "slim_lint", require: false
end

group :test do
  gem "capybara"
  gem "climate_control"
  gem "rack_session_access"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "vcr"
  gem "webmock"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
