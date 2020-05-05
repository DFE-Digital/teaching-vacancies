require_relative 'boot'

require 'kaminari'
require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
# require "action_cable/engine"
require 'sprockets/railtie'
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TeacherVacancyService
  class Application < Rails::Application
    # Configure Rack::Cors https://github.com/cyu/rack-cors
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'

        # Allow all domains access to jobs API
        resource '/api/v1/jobs/*',
          headers: :any,
          methods: [:get, :post, :delete, :put, :patch, :options, :head]
          
        # Only allow our domains access to coordinates API
        resource '/api/v1/coordinates/*',
          headers: :any,
          methods: :get,
          if: proc { |env|
            Rails.application.config.allowed_cors_origins.include?(env['HTTP_ORIGIN'])
          }
      end
    end

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1
    config.time_zone = 'Europe/London'

    # Automatically add `id: uuid` on any generated migrations
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end

    config.action_view.sanitized_allowed_tags = ['p', 'br', 'strong', 'em', 'ul', 'li', 'h1', 'h2', 'h3', 'h4', 'h5']

    # Settings in config/environments/* take precedence over those
    # specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Use custom error pages
    config.exceptions_app = routes

    config.autoload_paths += Dir[Rails.root.join('lib/logging')]
    config.autoload_paths += Dir[Rails.root.join('lib/modules')]

    config.active_job.queue_adapter = :sidekiq

    config.action_mailer.delivery_method = :notify
    config.action_mailer.deliver_later_queue_name = :mailers
    config.action_mailer.notify_settings = {
      api_key: ENV['NOTIFY_KEY']
    }
    config.action_mailer.default_url_options = { protocol: 'https' }
  end
end
