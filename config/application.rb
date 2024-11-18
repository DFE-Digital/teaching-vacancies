require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "active_storage/engine"
# require "action_cable/engine"
# require "rails/test_unit/railtie"
require "view_component/compile_cache"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# These are needed in configuration before autoloading kicks in
require_relative "../lib/fail_safe"
require_relative "../lib/modules/aws_ip_ranges"
require_relative "../lib/vcap_services"

require "rack-mini-profiler" if ENV.fetch("RACK_MINI_PROFILER", nil) == "true" && !Rails.env.production?

module TeachingVacancies
  class Application < Rails::Application
    config.load_defaults 7.0

    config.add_autoload_paths_to_load_path = false

    config.time_zone = "Europe/London"

    # Automatically add `id: uuid` on any generated migrations
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end

    config.action_view.sanitized_allowed_tags = %w[p br strong em ul li h1 h2 h3 h4 h5]
    config.action_view.default_form_builder = GOVUKDesignSystemFormBuilder::FormBuilder

    # Given we are using Lockbox, this ensures that Rails does not include unnecessary support for SHA-1,
    # which is deprecated and considered insecure.
    config.active_record.encryption.support_sha1_for_non_deterministic_encryption = false

    # Disable deprecated singular associations names.
    config.active_record.allow_deprecated_singular_associations_name = false

    # No longer run after_commit callbacks on the first of multiple Active Record
    # instances to save changes to the same database row within a transaction.
    config.active_record.run_commit_callbacks_on_first_saved_instances_in_transaction = false

    # Settings in config/environments/* take precedence over those
    # specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Use custom error pages
    config.exceptions_app = routes

    config.active_job.queue_adapter = :sidekiq

    config.action_mailer.delivery_method = :notify
    config.action_mailer.deliver_later_queue_name = :high
    config.action_mailer.notify_settings = {
      api_key: ENV.fetch("NOTIFY_KEY", nil),
    }
    config.action_mailer.perform_deliveries = ENV.fetch("DISABLE_EMAILS", nil) != "true"

    config.active_storage.routes_prefix = "/attachments"
    config.active_storage.resolve_model_to_route = :rails_storage_proxy

    # Specify the default serializer used by `MessageEncryptor` and `MessageVerifier`
    # instances.
    #
    # The legacy default is `:marshal`, which is a potential vector for
    # deserialization attacks in cases where a message signing secret has been
    # leaked.
    #
    # In Rails 7.1, the new default is `:json_allow_marshal` which serializes and
    # deserializes with `ActiveSupport::JSON`, but can fall back to deserializing
    # with `Marshal` so that legacy messages can still be read.
    #
    # In Rails 7.2, the default will become `:json` which serializes and
    # deserializes with `ActiveSupport::JSON` only.
    config.active_support.message_serializer = :json_allow_marshal

    config.active_support.use_message_serializer_for_metadata = true

    config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info").to_sym

    # Set up backing services through VCAP_SERVICES if running on AKS
    if ENV["VCAP_SERVICES"].present?
      vcap_services = VcapServices.new(ENV.fetch("VCAP_SERVICES", nil))

      config.redis_queue_url = vcap_services.named_service_url(:redis, "queue")
      config.redis_cache_url = vcap_services.named_service_url(:redis, "cache")
    else
      redis_url = ENV.fetch("REDIS_URL", "redis://localhost:6379")

      config.redis_queue_url = "#{redis_url}/0"
      config.redis_cache_url = "#{redis_url}/1"
    end

    config.app_role = ActiveSupport::StringInquirer.new(ENV.fetch("APP_ROLE", "unknown"))

    config.ab_tests = config_for(:ab_tests)

    config.local_authorities_extra_schools = config_for(:local_authorities_extra_schools)

    config.analytics = config_for(:analytics)
    config.analytics_pii = config_for(:analytics_pii)

    config.big_query_dataset = ENV.fetch("BIG_QUERY_DATASET", nil)

    config.enforce_local_authority_allowlist = ActiveModel::Type::Boolean.new.cast(ENV.fetch("ENFORCE_LOCAL_AUTHORITY_ALLOWLIST", nil))

    config.geocoder_lookup = :default

    config.landing_pages = config_for(:landing_pages)
    config.campaign_pages = config_for(:campaign_pages)

    config.maintenance_mode = ActiveModel::Type::Boolean.new.cast(ENV.fetch("MAINTENANCE_MODE", nil))

    config.assets.paths << Rails.root.join("node_modules/govuk-frontend/dist/govuk/assets")

    config.view_component.preview_paths << "#{Rails.root}/app/components/previews"
    config.view_component.preview_route = "/components"
    config.view_component.preview_controller = "PreviewsController"
    config.view_component.show_previews = true

    # GovUK One Login
    config.govuk_one_login_base_url = ENV.fetch("GOVUK_ONE_LOGIN_BASE_URL", nil)
    config.govuk_one_login_client_id = ENV.fetch("GOVUK_ONE_LOGIN_CLIENT_ID", nil)
    config.govuk_one_login_private_key = Rails.application.credentials.one_login&.private_key

    # TODO: We use Devise's `after_sign_out_path_for` to redirect users to DSI after signing out,
    # and have no way of disabling the foreign host redirect protection in that instance. Until
    # we figure out a way around that, this keeps the pre-Rails 7 default around.
    Rails.application.config.action_controller.raise_on_open_redirects = false

    # Do not treat an `ActionController::Parameters` instance as equal to an equivalent `Hash` by default.
    Rails.application.config.action_controller.allow_deprecated_parameters_hash_equality = false

    Rails.autoloaders.main.ignore(Rails.root.join("app/frontend"))

    config.after_initialize do |app|
      # Catch-all 404 route
      # Defined here instead of routes.rb to ensure it doesn't override gem/engine routes
      app.routes.append { match "*path", to: "errors#not_found", via: :all }
    end
  end
end
