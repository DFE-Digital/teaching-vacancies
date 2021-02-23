Geocoder.configure(
  timeout: 5,
  units: :mi,
  distance: :spherical,

  google: {
    api_key: Rails.env.test? ? "placeholder_key" : ENV.fetch("GOOGLE_LOCATION_SEARCH_API_KEY", ""),
    always_raise: [Geocoder::OverQueryLimitError],
  },

  uk_ordnance_survey_names: {
    api_key: Rails.env.test? ? "placeholder_key" : ENV.fetch("ORDNANCE_SURVEY_API_KEY", ""),
  },
)
