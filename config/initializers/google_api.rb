require "google/apis/indexing_v3"

GOOGLE_APIS_KEY = ENV.fetch("GOOGLE_APIS_KEY", "")
GOOGLE_LOCATION_SEARCH_API_KEY = ENV.fetch("GOOGLE_LOCATION_SEARCH_API_KEY", "")

if GOOGLE_APIS_KEY.empty?
  Rails.logger.info("***No GOOGLE_APIS_KEY set")
  return
end

# Configure the Google API client to use the API key
Google::Apis::RequestOptions.default.key = GOOGLE_APIS_KEY
