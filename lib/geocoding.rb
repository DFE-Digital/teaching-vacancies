class Geocoding
  attr_reader :params, :location

  def initialize(location, params = { params: { region: 'uk' } })
    @location = location
    @params = params
  end

  def coordinates
    Geocoder.coordinates(location, params) || no_match
  end

  private

  def no_match
    [0, 0]
  end
end
