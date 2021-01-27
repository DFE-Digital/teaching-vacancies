require "connection_pool"

Redis::Objects.redis =
  if Rails.env.test?
    MockRedis.new
  else
    ConnectionPool.new(size: 5, timeout: 5) do
      Redis.new(url: "#{Rails.configuration.redis_store_url}/1")
    end
  end
