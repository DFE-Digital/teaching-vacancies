Split.configure do |config|
  config.persistence = Split::Persistence::SessionAdapter
  config.redis = Rails.application.config.redis_cache_url
end
