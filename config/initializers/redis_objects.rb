require 'connection_pool'

redis_url = "#{ENV['REDIS_CACHE_URL']}/0"

Redis::Objects.redis = ConnectionPool.new(size: 5, timeout: 5) do
  Redis.new(url: redis_url)
end