class LocationLandingPage < LandingPage
  attr_reader :location

  def self.exists?(location)
    # TODO: This is the logic that previously was in the routes, should be tidied up
    LocationPolygon.include?(location.titleize)
  end

  def self.[](location)
    raise "No such location landing page: '#{location}'" unless exists?(location)

    new(location)
  end

  def initialize(location)
    @location = location
    @criteria = { location: location.titleize }
  end

  def name
    location.titleize
  end

  private

  def cache_key
    [:location_landing_page_count, location]
  end

  def translation_args
    super.merge(
      scope: [:landing_pages, "_location"],
      location: name,
    )
  end
end
