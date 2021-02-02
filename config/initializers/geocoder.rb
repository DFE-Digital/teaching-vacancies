require "auto_expire_cache_redis"

redis = Redis::Objects.redis
key = ENV.fetch("ORDNANCE_SURVEY_API_KEY", nil)

# Daily job alerts run every 24 hours and use this cache when searching for
# vacancies.  Give a little extra time in case the cron is slow.
redis_ttl = 26.hours.to_i

Geocoder.configure(
  lookup: :uk_ordnance_survey_names,
  api_key: key,
  timeout: 5,
  units: :mi,
  cache: AutoExpireCacheRedis.new(redis, redis_ttl),
  cache_prefix: "geocoder:",
  distance: :spherical,
)
