redis = Redis::Objects.redis
key = ENV.fetch('ORDNANCE_SURVEY_API_KEY', nil)

Geocoder.configure(
  lookup: :os_names,
  api_key: key,
  timeout: 5,
  units: :mi,
  cache: redis,
  cache_prefix: 'geocoder:',
  distance: :spherical
)
