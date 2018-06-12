
# config/initializers/geocoder.rb
Geocoder.configure(
  lookup: :google,

  # IP address geocoding service (see below for supported options):
  ip_lookup: :nil,

  # to use an API key:
  #:api_key => "...",

  # geocoding service request timeout, in seconds (default 3):
  timeout: 5,

  # set default units to kilometers:
  units: :mi,

  # caching (see below for details):
  #:cache => Redis.new,
  cache_prefix: 'geocoder:',
  distance: :spherical
)
