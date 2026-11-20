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
    # Applied to both the connect and the read timeout, so a slow Ordnance Survey delays the Google fallback by up to 2s
    # per call, and a search with a locality ("Bolton Abbey, Skipton") can make two calls.
    timeout: 1,
  },
)
