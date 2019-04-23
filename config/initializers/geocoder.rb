redis = Redis.new(url: ENV['REDIS_CACHE_URL'])
key = ENV.fetch('ORDNANCE_SURVEY_API_KEY', '')

Geocoder.configure(
  lookup: :os_names,
  api_key: key,
  timeout: 5,
  units: :mi,
  cache: redis,
  cache_prefix: 'geocoder:',
  distance: :spherical
)
