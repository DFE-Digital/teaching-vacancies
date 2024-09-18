source "https://rubygems.org"

ruby "3.3.5"

RAILS_VERSION = "~> 7.1.2".freeze
gem "actionmailer", RAILS_VERSION
gem "actionpack", RAILS_VERSION
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
gem "activerecord-postgis-adapter"
gem "activerecord-session_store"
gem "addressable"
gem "array_enum"
gem "aws-sdk-s3", require: false
gem "breasal"
gem "devise"
gem "dfe-analytics", github: "DFE-Digital/dfe-analytics", tag: "v1.14.2"
gem "factory_bot_rails"
gem "faker"
gem "friendly_id"
gem "front_matter_parser"
gem "geocoder"
gem "google-apis-drive_v3"
gem "google-apis-indexing_v3"
gem "google-cloud-bigquery"
gem "govuk-components", "~> 5.6.1"
gem "govuk_design_system_formbuilder", "~> 5.6.0"
gem "high_voltage"
gem "httparty"
gem "ipaddr"
gem "jbuilder"
gem "jwt"
gem "kramdown"
gem "lockbox"
gem "mail-notify"
gem "mimemagic"
gem "mini_magick"
gem "net-pop", github: "ruby/net-pop"
gem "net-sftp"
gem "nokogiri"
gem "noticed"
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
# TODO: Pinned to <7 until compatible with sidekiq-cron
gem "sidekiq", "<7"
gem "sidekiq-cron"
gem "skylight"
gem "slim-rails"
gem "validate_url"
gem "valid_email2"
gem "wicked"
gem "xml-sitemap"
gem "zendesk_api"

group :development do
  gem "amazing_print" # optional dependency of `rails_semantic_logger`
  gem "aws-sdk-ssm"
  gem "better_errors"
  gem "binding_of_caller"
  gem "listen"
  gem "solargraph"
  gem "spring"
  gem "spring-commands-rspec"
  gem "spring-watcher-listen"
  gem "web-console"
end

group :development, :test do
  gem "brakeman"
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "database_consistency", require: false
  gem "dotenv-rails"
  gem "launchy", "~> 3.0"
  gem "parallel_tests"
  gem "pry"
  gem "pry-byebug"
  gem "pry-rails"
  gem "rack-mini-profiler", require: false
  gem "rails-controller-testing"
  gem "rspec-rails"
  gem "rubocop-performance"
  gem "rubocop-rails"
  gem "rubocop-rspec"
  gem "slim_lint", require: false
end

group :test do
  gem "capybara"
  gem "climate_control"
  gem "fastimage"
  gem "rack_session_access"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "timecop"
  gem "vcr"
  gem "webmock"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
