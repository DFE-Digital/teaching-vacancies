source "https://rubygems.org"

ruby "3.4.6"

RAILS_VERSION = "< 8.1".freeze
gem "actionmailer", RAILS_VERSION
gem "actionpack", RAILS_VERSION
gem "actionpack-action_caching"
gem "actiontext", RAILS_VERSION
gem "activejob", RAILS_VERSION
gem "activemodel", RAILS_VERSION
gem "activerecord", RAILS_VERSION
gem "activestorage", RAILS_VERSION
gem "activesupport", RAILS_VERSION
gem "cssbundling-rails"
gem "jsbundling-rails"
gem "propshaft"
gem "railties", RAILS_VERSION

gem "activerecord-import"
gem "activerecord-postgis-adapter", ">= 10.0.1"
gem "activerecord-session_store"
gem "active_storage_validations"
gem "addressable"
gem "array_enum"
gem "aws-sdk-s3"
gem "breasal"
gem "business_time"
gem "chartkick"
gem "devise"
gem "dfe-analytics", github: "DFE-Digital/dfe-analytics", tag: "v1.15.10"
gem "discard", "~> 1.4"
gem "draper"
gem "factory_bot_rails"
gem "faker"
gem "friendly_id"
gem "front_matter_parser"
gem "geocoder"
gem "google-apis-drive_v3"
gem "google-apis-indexing_v3"
gem "google-cloud-bigquery"
gem "govuk-components", "~> 5.11.1"
gem "govuk_design_system_formbuilder", "~> 5.13.0"
gem "high_voltage"
gem "httparty"
# needed for processing of message attachments
gem "image_processing"
gem "ipaddr"
gem "jbuilder"
gem "json-schema"
gem "jwt"
gem "kramdown"
gem "lockbox"
gem "mail-notify"
gem "mimemagic"
gem "mini_magick"
gem "mutex_m"
gem "net-sftp"
gem "nokogiri"
gem "noticed", ">= 2.5"
gem "omniauth"
gem "omniauth_openid_connect"
gem "omniauth-rails_csrf_protection", "~> 1.0"
gem "online_migrations"
gem "pagy", "< 9"
gem "paper_trail"
gem "paper_trail-globalid"
gem "parslet"
gem "pg"
gem "pg_search"
gem "prawn-table"
gem "puma"
gem "rack-attack"
gem "rack-cors"
gem "rails_semantic_logger"
gem "recaptcha"
gem "redis"
gem "rgeo-geojson"
gem "rswag-api"
gem "rswag-ui"
gem "ruby-limiter"
gem "rubyzip"
gem "sanitize"
gem "sentry-rails"
gem "sentry-ruby"
gem "sentry-sidekiq"
# TODO: Pinned to <7 until compatible with sidekiq-cron
gem "sidekiq", "<7"
gem "sidekiq-cron"
gem "sidekiq-limit_fetch"
gem "skylight"
gem "slim-rails"
gem "validate_url"
gem "valid_email2"
# this upgrade creates 848 test failures
gem "view_component", "< 4"
gem "wicked"
gem "xml-sitemap"
gem "zendesk_api"

group :development do
  gem "amazing_print" # optional dependency of `rails_semantic_logger`
  gem "aws-sdk-ssm"
  gem "better_errors"
  gem "binding_of_caller"
  gem "listen"
  gem "rubocop-factory_bot", require: false
  gem "rubocop-govuk", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rspec_rails", require: false
  gem "solargraph"
  gem "web-console"
end

group :development, :test do
  gem "axe-core-capybara"
  gem "axe-core-rspec"
  gem "brakeman"
  gem "byebug", platforms: %i[mri windows]
  gem "database_consistency", require: false
  gem "debug", ">= 1.0.0", require: false
  gem "dotenv-rails"
  gem "guard-bundler", "~> 3.0", require: false
  gem "guard-rspec", require: false
  gem "guard-rubocop", "~> 1.5", require: false
  gem "guard-slim_lint"
  gem "launchy", "~> 3.1"
  gem "parallel_tests"
  gem "pdf-inspector", require: "pdf/inspector"
  gem "pry"
  gem "pry-byebug"
  gem "pry-rails"
  gem "rack-mini-profiler", require: false
  gem "rails-controller-testing"
  gem "rspec-rails"
  gem "rswag-specs"
  gem "slim_lint", require: false
  gem "undercover", require: false
end

group :test do
  gem "capybara"
  gem "climate_control"
  gem "cuprite"
  gem "fastimage"
  gem "mock_redis"
  gem "rack_session_access"
  gem "redis-client"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "simplecov", require: false
  # Lcov 0.9 breaks undercover's LCov parser
  gem "simplecov-lcov", "< 0.10", require: false
  gem "site_prism"
  gem "uri-query_params"
  gem "vcr"
  gem "webmock"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[windows jruby]
