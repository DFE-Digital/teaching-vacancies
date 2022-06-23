require_relative "boot"

require "kaminari"
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
# require 'sprockets/railtie'
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

module TeacherVacancyService
  class Application < Rails::Application
    config.load_defaults 6.1

    config.time_zone = "Europe/London"

    # Automatically add `id: uuid` on any generated migrations
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end

    config.action_view.sanitized_allowed_tags = %w[p br strong em ul li h1 h2 h3 h4 h5]
    config.action_view.default_form_builder = GOVUKDesignSystemFormBuilder::FormBuilder

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

    config.active_storage.routes_prefix = "/attachments"
    config.active_storage.resolve_model_to_route = :rails_storage_proxy

    config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info").to_sym

    # Set up backing services through VCAP_SERVICES if running on Cloudfoundry (GOV.UK PaaS)
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

    config.maintenance_mode = ActiveModel::Type::Boolean.new.cast(ENV.fetch("MAINTENANCE_MODE", nil))

    config.view_component.preview_paths << "#{Rails.root}/app/components/previews"
    config.view_component.preview_route = "/components"
    config.view_component.preview_controller = "PreviewsController"
    config.view_component.show_previews = true

    # TODO: We use Devise's `after_sign_out_path_for` to redirect users to DSI after signing out,
    # and have no way of disabling the foreign host redirect protection in that instance. Until
    # we figure out a way around that, this keeps the pre-Rails 7 default around.
    Rails.application.config.action_controller.raise_on_open_redirects = false

    Rails.autoloaders.main.ignore(Rails.root.join("app/frontend"))

    config.after_initialize do |app|
      # Catch-all 404 route
      # Defined here instead of routes.rb to ensure it doesn't override gem/engine routes
      app.routes.append { match "*path", to: "errors#not_found", via: :all }
    end
  end
end
