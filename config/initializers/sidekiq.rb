return if Rails.env.test?

options = {
  concurrency: Integer(ENV.fetch("RAILS_MAX_THREADS", 5)),
}

# Redis concurrency must be plus 5 https://github.com/mperham/sidekiq/wiki/Using-Redis#complete-control
Sidekiq.configure_server do |config|
  config[:concurrency] = options.fetch(:concurrency)
  config.logger.level = Logger::WARN
  config.redis = { url: Rails.configuration.redis_queue_url, network_timeout: 5, size: config[:concurrency] + 5 }
end

Sidekiq.configure_client do |config|
  config[:concurrency] = options.fetch(:concurrency)
  config.redis = { url: Rails.configuration.redis_queue_url, network_timeout: 5, size: config[:concurrency] + 5 }
end

