source "https://rubygems.org"

ruby "4.0.1"

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
# Use Addressable::URI.heuristic_parse to parse string-based URLs
gem "addressable"
gem "array_enum"
gem "aws-sdk-s3"
#  used during assets:precompile
gem "azure-blob", require: false
gem "business_time"
gem "chartkick"
gem "devise"
gem "dfe-analytics", github: "DFE-Digital/dfe-analytics", tag: "v1.15.15"
gem "discard", "~> 1.4"
gem "draper"
# we populate seeds from factory bot in review apps
# These could be moved into test scope
gem "factory_bot_rails"
gem "faker"
# more uk-friendly fakes available
gem "ffaker"

# slugs for vacancies
gem "friendly_id"
# guidance pages content
gem "front_matter_parser"
# postcode and location distance calculations
gem "geocoder"
# These 2 can be removed when we complete move to Azure attachment checking
gem "google-apis-drive_v3"
gem "google-apis-indexing_v3"
# Only used for DFE Analytics - but sometimes we need to pin the version manually
gem "google-cloud-bigquery"
gem "govuk-components", "6.1.0"
gem "govuk_design_system_formbuilder", "~> 6.1.0"
#  used for job statistics by month, quarter year etc
gem "groupdate"
#  guidance pages
gem "high_voltage"
# HTTP client for downloading GIAS data
gem "httparty"
# needed for processing of message attachments
gem "image_processing"
# startard library for creating IPAddresses. Used in production config
gem "ipaddr"
# API JSON building
gem "jbuilder"
# ATS client schema checks
gem "json-schema"

# used for DFE Signin support
# implicitly brought in by big_query as transitive dependency
gem "jwt"
# guidance pages support
gem "kramdown"
# encyrption
gem "lockbox"
# sending emails for GOV UK notify
gem "mail-notify"
# for marking MS office files with a MIME type
gem "mimemagic"
# convert uploaded images to correct sizes
gem "mini_magick"
gem "mutex_m"
# DWP integration
gem "net-sftp"
# used for making XMl site map and parsing import sources
# is a current dependency of rails, but might not continue that way
gem "nokogiri"
# in-application notifications
gem "noticed", ">= 2.5"
#  authentication with DFE Login
gem "omniauth"
gem "omniauth_openid_connect"
gem "omniauth-rails_csrf_protection", "~> 2.0"
# safer migrations on live databases with large tables
gem "online_migrations"
gem "ostruct"
# pagination of large data sets
gem "pagy", "~> 9.4" # Omit the patch segment to avoid breaking changes
# track changes to a vacancy over time
gem "paper_trail"
# https://github.com/ankit1910/paper_trail-globalid - adds 'actor' to paper_trail
gem "paper_trail-globalid"
# search keyword parsing into filters
gem "parslet"
gem "pg"
#  vector searches in postgres used for vacancy search weightings
gem "pg_search"
# PDF table support
gem "prawn-table"
gem "puma"
gem "rack-attack"
gem "rack-cors"
gem "rails", RAILS_VERSION # Explicitly declare rails so we can do a "bundle update rails" when needed.
gem "rails_semantic_logger"
gem "recaptcha"
# Geographic point conversions
gem "rgeo-geojson"
gem "rgeo-proj4"
# open API docs for external client integrations
gem "rswag-api"
gem "rswag-ui"
# more limiting of Govuk Notify API requests
gem "ruby-limiter"
# needed to make zipfiles - often in sidekiq jobs
gem "rubyzip"
gem "sentry-rails"
gem "sentry-ruby"
gem "sentry-sidekiq"
# sidekiq 7 needs Redis 6.2.x which isn't available on Azure (yet)
gem "sidekiq", "<7"
gem "sidekiq-cron"
# throttle sidekiq requests to avoid overwhelming the Govuk Notify API
gem "sidekiq-limit_fetch"
# Skylight performance monitoring https://www.skylight.io/login
gem "skylight"
gem "slim-rails"
gem "turbo-rails"
# Used to validate the web link for external 'website' applications
gem "validate_url"
# Used to validate email addresses
gem "valid_email2"
gem "view_component", "~> 4.6.0"
gem "wicked"
gem "xml-sitemap"
# Zendesk support integration
gem "zendesk_api"

group :development do
  gem "amazing_print" # optional dependency of `rails_semantic_logger`
  gem "aws-sdk-ssm"
  gem "better_errors"
  gem "binding_of_caller"
  gem "listen"
  gem "rubocop-factory_bot", require: false
  gem "rubocop-govuk", "> 5.2.0", require: false
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
  gem "fantaskspec"
  gem "guard-bundler", "~> 3.1", require: false
  gem "guard-rspec", require: false
  gem "guard-rubocop", "~> 1.5", require: false
  gem "guard-shell", require: false
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
  # needed to support mock_redis
  gem "redis-client"
  # maintained fork of rspec-retry
  gem "rspec-rebound"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "simplecov", require: false
  gem "site_prism"
  gem "uri-query_params"
  gem "vcr"
  gem "webmock"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[windows jruby]
