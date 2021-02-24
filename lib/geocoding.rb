class Geocoding
  CACHE_DURATION = 30.days

  attr_reader :location

  def initialize(location)
    @location = location
  end

  def coordinates
    return Geocoder::DEFAULT_STUB_COORDINATES if Rails.application.config.geocoder_lookup == :test

    geocoded_location = begin
      Geocoder.coordinates(location, lookup: :google, components: "country:gb")
    rescue Geocoder::OverQueryLimitError
      Rails.logger.error("Google Geocoding API responded with OVER_QUERY_LIMIT")
      Geocoder.coordinates(location, lookup: :uk_ordnance_survey_names)
    end

    return no_match if geocoded_location.blank?

    Rails.cache.fetch([:geocoding, location], expires_in: CACHE_DURATION) do
      geocoded_location
    end
  end

  private

  def no_match
    Rails.logger.info("The Geocoder API returned no match (0, 0) for '#{location}'. This was not cached.")
    [0, 0]
  end
end
