return if Rails.env.test?

redis_url = "#{ENV['REDIS_QUEUE_URL']}/0"

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url,  network_timeout: 5 }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url,  network_timeout: 5 }
end
