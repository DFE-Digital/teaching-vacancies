# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # While tests run files are not watched, reloading is not necessary.
  config.enable_reloading = false

  # Configure the domains permitted to access coordinates API
  config.allowed_cors_origin = proc { "https://allowed.test.website" }

  # Eager loading loads your entire application. When running a single test locally,
  # this is usually not necessary, and can slow down your test suite. However, it's
  # recommended that you enable it in continuous integration systems to ensure eager
  # loading is working properly before deploying your code.
  config.eager_load = ENV["CI"].present?

  # Configure public file server for tests with cache-control for performance.
  config.public_file_server.headers = { "cache-control" => "public, max-age=3600" }

  # Show full error reports.
  config.consider_all_requests_local = true
  config.cache_store = :null_store

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = :none

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Store uploaded files on the local file system in a temporary directory.
  config.active_storage.service = :test

  config.active_job.queue_adapter = :test

  config.action_mailer.perform_caching = false
  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test
  config.action_mailer.default_options = {
    from: "mail@example.com",
  }

  # Raise an error when encountering deprecated behaviour
  config.active_support.deprecation = :raise

  # Raises error for missing translations.
  config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  config.middleware.use RackSessionAccess::Middleware

  config.bigquery_dataset = "test_dataset"

  require "dfe_sign_in/fake_sign_out_endpoint"
  ENV["DFE_SIGN_IN_ISSUER"] = "http://fake.dsi.example.com"
  config.middleware.insert_before 0, DfeSignIn::FakeSignOutEndpoint

  # Raise error when a before_action's only/except options reference missing actions.
  config.action_controller.raise_on_missing_callback_actions = true

  # Ensure that query logs are not verbose in tests (tests are way slower when enabled).
  config.active_record.verbose_query_logs = false
  config.active_record.query_log_tags_enabled = false
  config.log_level = :fatal

  # we don't need strict mx validation (checking MX records etc) in test mode
  config.strict_mx_validation = false
end

# Avoid OmniAuth output in tests:
# I, [2018-04-03T15:01:45.960289 #297]  INFO -- omniauth: (azureactivedirectory) Request phase initiated.
OmniAuth.config.logger = Logger.new(File::NULL)
OmniAuth.config.on_failure = proc { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}

# Lockbox key token is specific to test environment
Lockbox.master_key = "5b1f54d9c713b028b34a34b2bf95b4e22150fcd636069efc67cf7bff64ddfb04"
