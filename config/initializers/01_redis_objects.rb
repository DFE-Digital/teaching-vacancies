require 'connection_pool'

Redis::Objects.redis = if Rails.env.test?
                         MockRedis.new
                       else
                         ConnectionPool.new(size: 5, timeout: 5) do
                           Redis.new(url: "#{ENV['REDIS_CACHE_URL']}/1")
                         end
                       end
