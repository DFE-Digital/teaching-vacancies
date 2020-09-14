class Geocoding
  attr_reader :params, :location

  def initialize(location)
    @location = location
  end

  def coordinates
    Geocoder.coordinates(location) || no_match
  end

private

  def no_match
    [0, 0]
  end
end
