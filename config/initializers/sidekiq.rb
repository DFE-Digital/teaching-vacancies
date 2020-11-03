return if Rails.env.test?

redis_url = "#{REDIS_URL}/0"

options = {
  concurrency: Integer(ENV.fetch("RAILS_MAX_THREADS") { 5 }),
}

# Redis concurrency must be plus 5 https://github.com/mperham/sidekiq/wiki/Using-Redis#complete-control
Sidekiq.configure_server do |config|
  config.options.merge!(options)
  config.redis = { url: redis_url, network_timeout: 5, size: config.options[:concurrency] + 5 }
end

Sidekiq.configure_client do |config|
  config.options.merge!(options)
  config.redis = { url: redis_url, network_timeout: 5, size: config.options[:concurrency] + 5 }
end

schedule_file = "config/schedule.yml"

if File.exist?(schedule_file) && Sidekiq.server?
  Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
end
