return if Rails.env.test?

options = {
  concurrency: Integer(ENV.fetch("RAILS_MAX_THREADS", 5)),
}

# Redis concurrency must be plus 5 https://github.com/mperham/sidekiq/wiki/Using-Redis#complete-control
Sidekiq.configure_server do |config|
  config.options.merge!(options)
  config.logger.level = Logger::WARN
  config.redis = { url: Rails.configuration.redis_queue_url, network_timeout: 5, size: config.options[:concurrency] + 5 }
end

Sidekiq.configure_client do |config|
  config.options.merge!(options)
  config.redis = { url: Rails.configuration.redis_queue_url, network_timeout: 5, size: config.options[:concurrency] + 5 }
end

schedule_file = "config/schedule.yml"

if File.exist?(schedule_file) && Sidekiq.server?
  Rails.application.config.after_initialize do
    Sidekiq::Cron::Job.load_from_hash! YAML.load_file(schedule_file)
  end
end
