Rails.application.configure do
  # Settings specified here will take precedence over those in
  # config/application.rb.

  # Configure the domains permitted to access coordinates API
  config.allowed_cors_origin = proc { "https://allowed.test.website" }

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

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

  # Algolia index prefix must be nil in order for VCR system specs to run
  config.algolia_index_prefix = nil

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
end

# Avoid OmniAuth output in tests:
# I, [2018-04-03T15:01:45.960289 #297]  INFO -- omniauth: (azureactivedirectory) Request phase initiated.
OmniAuth.config.logger = Logger.new("/dev/null")
OmniAuth.config.on_failure = proc { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}
