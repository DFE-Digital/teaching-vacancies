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
    end || no_match
  end

  private

  def no_match
    Rails.logger.info("The Geocoder API returned no match (0, 0) for '#{location}'. This was not cached.")
    [0, 0]
  end
end
