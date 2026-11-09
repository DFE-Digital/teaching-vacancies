require "geocoding"

Geocoder.configure(
  timeout: 5,
  units: :mi,
  distance: :spherical,
  http_headers: { "User-Agent" => "Teaching Vacancies Service teaching.vacancies@education.gov.uk" },

  google: {
    api_key: ENV.fetch("GOOGLE_LOCATION_SEARCH_API_KEY", "placeholder_key"),
    always_raise: [Geocoder::OverQueryLimitError],
  },

  uk_ordnance_survey_names: {
    api_key: Rails.env.test? ? "placeholder_key" : ENV.fetch("ORDNANCE_SURVEY_API_KEY", ""),
  },

  cache: Redis.new(url: Rails.application.config.redis_cache_url),
  cache_options: { expiration: Geocoding::CACHE_DURATION },
)
