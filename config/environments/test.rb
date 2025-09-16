require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in
  # config/application.rb.

  # The application uses multiple services for storing files. This sets up a default value which gets overridden
  # in every specific use case.
  config.active_storage.service = :amazon_s3_documents

  # Configure the domains permitted to access coordinates API
  config.allowed_cors_origin = proc { "https://allowed.test.website" }

  config.enable_reloading = true

  config.action_view.cache_template_loading = true

  # Eager loading loads your whole application. When running a single test locally,
  # this probably isn't necessary. It's a good idea to do in a continuous integration
  # system, or in some way before deploying your code.
  config.eager_load = ENV["CI"].present?

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=#{1.hour.to_i}",
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = :none

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  config.active_job.queue_adapter = :test

  config.action_mailer.perform_caching = false
  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test
  config.action_mailer.default_options = {
    from: "mail@example.com",
  }

  # Raise an error when encountering deprecated behaviour or missing translations
  config.active_support.deprecation = :raise
  config.i18n.raise_on_missing_translations = true

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Specify if an `ArgumentError` should be raised if `Rails.cache` `fetch` or
  # `write` are given an invalid `expires_at` or `expires_in` time.
  config.active_support.raise_on_invalid_cache_expiration_time = true

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  config.middleware.use RackSessionAccess::Middleware

  config.bigquery_dataset = "test_dataset"

  # Use test geocoder lookup, unless otherwise specified
  config.geocoder_lookup = :test

  require "dfe_sign_in/fake_sign_out_endpoint"
  ENV["DFE_SIGN_IN_ISSUER"] = "http://fake.dsi.example.com"
  config.middleware.insert_before 0, DfeSignIn::FakeSignOutEndpoint

  config.log_file_size = 100.megabytes

  # Raise error when a before_action's only/except options reference missing actions
  config.action_controller.raise_on_missing_callback_actions = true
end

# Avoid OmniAuth output in tests:
# I, [2018-04-03T15:01:45.960289 #297]  INFO -- omniauth: (azureactivedirectory) Request phase initiated.
OmniAuth.config.logger = Logger.new(File::NULL)
OmniAuth.config.on_failure = proc { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}

# Lockbox key token is specific to test environment
Lockbox.master_key = "5b1f54d9c713b028b34a34b2bf95b4e22150fcd636069efc67cf7bff64ddfb04"
