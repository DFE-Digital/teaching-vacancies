Rails.application.configure do
  # Settings specified here will take precedence over those in
  # config/application.rb.

  # Configure the domains permitted to access coordinates API
  config.allowed_cors_origin = proc { "https://allowed.test.website" }

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  # Set to `false` to support Spring preloading in test
  config.cache_classes = false

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=#{1.hour.seconds.to_i}",
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

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

  config.cache_store = :null_store

  config.middleware.use RackSessionAccess::Middleware

  config.big_query_dataset = "test_dataset"

  # Use test geocoder lookup, unless otherwise specified
  config.geocoder_lookup = :test

  # Bullet gem configuration
  config.after_initialize do
    Bullet.enable = true
    # TODO: Causing lots of issues with FactoryBot-created qualification results
    #   see: https://github.com/flyerhzm/bullet/issues/435
    Bullet.raise = false
  end

  config.active_storage.service = :test

  require "fake_dsi_sign_out_endpoint"
  ENV["DFE_SIGN_IN_ISSUER"] = "http://fake.dsi.example.com"
  config.middleware.insert_before 0, FakeDsiSignOutEndpoint
end

# Avoid OmniAuth output in tests:
# I, [2018-04-03T15:01:45.960289 #297]  INFO -- omniauth: (azureactivedirectory) Request phase initiated.
OmniAuth.config.logger = Logger.new("/dev/null")
OmniAuth.config.on_failure = proc { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}

# Lockbox key token is specific to test environment
Lockbox.master_key = "5b1f54d9c713b028b34a34b2bf95b4e22150fcd636069efc67cf7bff64ddfb04"
