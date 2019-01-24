redis = Redis.new(url: ENV['REDIS_CACHE_URL'])
key = ENV.fetch('GOOGLE_GEOCODING_API_KEY', '')

Geocoder.configure(
  lookup: :google,
  api_key: key,
  timeout: 5,
  units: :mi,
  cache: redis,
  cache_prefix: 'geocoder:',
  distance: :spherical
)
