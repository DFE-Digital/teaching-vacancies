GoogleDistanceMatrix.configure_defaults do |config|
  config.google_api_key = ENV['GOOGLE_GEOCODING_API_KEY']
end