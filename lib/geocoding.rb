class Geocoding
  CACHE_DURATION = 30.days

  attr_reader :params, :location

  def initialize(location)
    @location = location
  end

  def coordinates
    Rails.cache.fetch([:geocoding, location], expires_in: CACHE_DURATION) do
      Geocoder.coordinates(location) || no_match
    end
  end

  private

  def no_match
    [0, 0]
  end
end
