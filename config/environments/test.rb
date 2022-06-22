require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in
  # config/application.rb.

  # Configure the domains permitted to access coordinates API
  config.allowed_cors_origin = proc { "https://allowed.test.website" }

  # `cache_classes` should be false under Spring as of Rails 7 - if we revisit our use of Spring,
  # we should turn this back to true and stop setting `action_view.cache_template_loading`.
  config.cache_classes = false
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
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false
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

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  config.middleware.use RackSessionAccess::Middleware

  config.big_query_dataset = "test_dataset"

  # Use test geocoder lookup, unless otherwise specified
  config.geocoder_lookup = :test

  config.active_storage.service = :test

  require "fake_dsi_sign_out_endpoint"
  ENV["DFE_SIGN_IN_ISSUER"] = "http://fake.dsi.example.com"
  config.middleware.insert_before 0, FakeDSISignOutEndpoint
end

# Avoid OmniAuth output in tests:
# I, [2018-04-03T15:01:45.960289 #297]  INFO -- omniauth: (azureactivedirectory) Request phase initiated.
OmniAuth.config.logger = Logger.new("/dev/null")
OmniAuth.config.on_failure = proc { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}

# Lockbox key token is specific to test environment
Lockbox.master_key = "5b1f54d9c713b028b34a34b2bf95b4e22150fcd636069efc67cf7bff64ddfb04"
