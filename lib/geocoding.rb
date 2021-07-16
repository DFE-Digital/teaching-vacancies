class Geocoding
  CACHE_DURATION = 30.days

  attr_reader :location

  def initialize(location)
    @location = location
  end

  def coordinates
    return Geocoder::DEFAULT_STUB_COORDINATES if Rails.application.config.geocoder_lookup == :test

    Rails.cache.fetch([:geocoding, location], expires_in: CACHE_DURATION, skip_nil: true) do
      Geocoder.coordinates(location, lookup: :google, components: "country:gb")
    rescue Geocoder::OverQueryLimitError
      Rails.logger.error("Google Geocoding API responded with OVER_QUERY_LIMIT")
      Geocoder.coordinates(location, lookup: :uk_ordnance_survey_names)
    end || no_coordinates_match
  end

  def postcode_from_coordinates
    return Geocoder::DEFAULT_LOCATION if Rails.application.config.geocoder_lookup == :test

    Rails.cache.fetch([:geocoding, location], expires_in: CACHE_DURATION, skip_nil: true) do
      result = Geocoder.search(location, lookup: :google).first # specifying `components: country:gb` would force the result to be a country
      result.data["address_components"].select { |line| "postal_code".in?(line["types"]) }.first["short_name"]
    rescue Geocoder::OverQueryLimitError
      Rails.logger.error("Google Geocoding API responded with OVER_QUERY_LIMIT")
      result = Geocoder.search(location).first
      Rails.logger.error("Geocoding API responded with error: #{result.first.data["error"]}") if result.first.data["error"].present?
      result.data["address"]["postcode"]
    end || no_postcode_match
  end

  private

  def no_coordinates_match
    Rails.logger.info("The Geocoder API returned no coordinates match (0, 0) for '#{location}'. This was not cached.")
    [0, 0]
  end

  def no_postcode_match
    Rails.logger.info("The Geocoder API returned no postcode match for '#{location}'. This was not cached.")
    ""
  end
end
