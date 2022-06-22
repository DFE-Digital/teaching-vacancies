require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in
  # config/application.rb.

  # Configure the domains permitted to access coordinates API
  config.allowed_cors_origin = proc { "https://#{DOMAIN}" }

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  # Allow Web Console from outside devcontainer
  config.web_console.permissions = "172.0.0.0/8" if ENV["DEVCONTAINER"].present?

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :redis_cache_store, { url: config.redis_cache_url }
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}",
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Raise an error when encountering deprecated behaviour
  config.active_support.deprecation = :raise

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  logger           = ActiveSupport::Logger.new($stdout)
  logger.formatter = config.log_formatter
  config.logger    = ActiveSupport::TaggedLogging.new(logger)

  # Annotate rendered view with file names.
  config.action_view.annotate_rendered_view_with_filenames = true

  config.active_storage.service = :local
end
