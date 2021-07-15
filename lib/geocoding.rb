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

    Rails.cache.fetch([:postcode_from_coords, location], expires_in: CACHE_DURATION, skip_nil: true) do
      result = Geocoder.search(location, lookup: :google).first
      return no_postcode_match if result.nil?

      result.data["address_components"].find { |line| "postal_code".in?(line["types"]) }["short_name"]
    rescue Geocoder::OverQueryLimitError
      Rails.logger.error("Google Geocoding API responded with OVER_QUERY_LIMIT")
      result = Geocoder.search(location, lookup: :nominatim).first.data
      if result["error"].present?
        Rails.logger.error("Geocoding Nominatim API responded with error: #{result['error']}")
        return no_postcode_match
      end
      result["address"]["postcode"]
    end
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
