Geocoder.configure(
  lookup: :google,
  api_key: ENV.fetch("GOOGLE_LOCATION_SEARCH_API_KEY", ""),
  timeout: 5,
  units: :mi,
  distance: :spherical,
)
