Geocoder.configure(
  lookup: :uk_ordnance_survey_names,
  api_key: ENV.fetch("ORDNANCE_SURVEY_API_KEY", nil),
  timeout: 5,
  units: :mi,
  distance: :spherical,
)
