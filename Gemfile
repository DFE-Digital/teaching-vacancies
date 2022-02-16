source "https://rubygems.org"

ruby "3.1.0"

RAILS_VERSION = "~> 6.1.4.1".freeze
gem "actionmailer", RAILS_VERSION
gem "actionpack", RAILS_VERSION
gem "activejob", RAILS_VERSION
gem "activemodel", RAILS_VERSION
gem "activerecord", RAILS_VERSION
gem "activestorage", RAILS_VERSION
gem "activesupport", RAILS_VERSION
gem "railties", RAILS_VERSION

gem "activerecord-import"
gem "activerecord-postgis-adapter"
gem "activerecord-session_store"
gem "addressable"
gem "array_enum"
gem "aws-sdk-s3", require: false
gem "breasal"
gem "browser"
gem "colorize"
gem "devise"
gem "factory_bot_rails"
gem "faker"
gem "friendly_id"
gem "front_matter_parser"
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
gem "lockbox"
gem "mail-notify"
gem "mimemagic"
gem "noticed"
gem "omniauth", "< 2" # TODO: Pinned pending fixes
gem "omniauth_openid_connect", "< 0.4" # TODO: Pinned pending fixes
gem "parslet"
gem "pg"
gem "puma"
gem "rack-attack"
gem "rack-cors"
gem "rails-html-sanitizer"
gem "rails_semantic_logger"
gem "recaptcha"
gem "redis"
gem "sanitize"
gem "sentry-rails"
gem "sentry-ruby"
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

# TODO: These are required by Ruby 3.1, but not automatically pulled in by Rails right now
#  c.f. https://github.com/rails/rails/commit/5dd292f5511fedd91833dc8482baf696cb821af6
#  This can be removed once we have a version of Rails that includes them in its dependencies.
gem "net-imap", require: false
gem "net-pop", require: false
gem "net-smtp", require: false

group :development do
  gem "amazing_print" # optional dependency of `rails_semantic_logger`
  gem "aws-sdk-ssm"
  gem "launchy"
  gem "listen"
  gem "solargraph", require: false
  gem "spring"
  gem "spring-commands-rspec"
  # TODO: Add back when version supporting Spring >= 4.0 is released
  #       see https://github.com/rails/spring-watcher-listen/issues/27
  # gem "spring-watcher-listen"
  gem "web-console"
end

group :development, :test do
  gem "axe-core-api"
  gem "axe-core-capybara"
  gem "axe-core-rspec"
  gem "brakeman"
  gem "bullet"
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "dotenv-rails"
  gem "pry"
  gem "pry-byebug"
  gem "pry-rails"
  gem "rack-mini-profiler"
  gem "rails-controller-testing"
  gem "rspec-rails", "5.0.2" # TODO: Pinned pending https://github.com/rspec/rspec-rails/pull/2570
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
  gem "simplecov"
  gem "vcr"
  gem "webmock"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
