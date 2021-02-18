class Geocoding
  CACHE_DURATION = 30.days

  attr_reader :params, :location

  def initialize(location)
    @location = location
  end

  def coordinates
    Rails.cache.fetch([:geocoding, location], expires_in: CACHE_DURATION) do
      Geocoder.coordinates(location, components: "country:GB") || no_match
    end
  end

  private

  def no_match
    Rails.logger.info("The Geocoder API returned no match (0, 0) for '#{location}'. This was then cached.")
    return [0, 0]
  end
end
