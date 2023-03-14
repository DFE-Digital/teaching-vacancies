class Geocoding
  CACHE_DURATION = 30.days

  attr_reader :location

  def self.test_coordinates
    Geocoder::DEFAULT_STUB_COORDINATES
  end

  def initialize(location)
    @location = location
  end

  def coordinates
    return self.class.test_coordinates if Rails.application.config.geocoder_lookup == :test

    Rails.cache.fetch([:geocoding, location], expires_in: CACHE_DURATION, skip_nil: true) do
      Geocoder.coordinates(location, lookup: :google, components: "country:gb")
    rescue Geocoder::OverQueryLimitError
      Rails.logger.error("Google Geocoding API responded with OVER_QUERY_LIMIT")
      Geocoder.coordinates(location, lookup: :uk_ordnance_survey_names)
    end || no_coordinates_match
  end

  def postcode_from_coordinates
    return Geocoder::DEFAULT_LOCATION if Rails.application.config.geocoder_lookup == :test

    Rails.cache.fetch([:postcode_from_coords, location], expires_in: CACHE_DURATION, skip_nil: true) do
      result = Geocoder.search(location, lookup: :google).first
      result.data["address_components"].find { |line| "postal_code".in?(line["types"]) }&.dig("short_name") unless result.nil?
    rescue Geocoder::OverQueryLimitError
      Rails.logger.error("Google Geocoding API responded with OVER_QUERY_LIMIT")
      fallback_postcode_from_coords
    end || no_postcode_match
  end

  private

  def fallback_postcode_from_coords(service: :nominatim)
    result = Geocoder.search(location, lookup: service).first.data
    if result["error"].present?
      Rails.logger.error("Geocoding Nominatim API responded with error: #{result['error']}")
      no_postcode_match
    else
      result["address"]["postcode"]
    end
  end

  def no_coordinates_match
    Rails.logger.info("The Geocoder API returned no coordinates match (0, 0) for '#{location}'. This was not cached.")
    [0, 0]
  end

  def no_postcode_match
    Rails.logger.info("The Geocoder API returned no postcode match for '#{location}'. This was not cached.")
    nil
  end
end
