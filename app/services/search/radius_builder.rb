class Search::RadiusBuilder
  DEFAULT_RADIUS_FOR_POINT_SEARCHES = 10
  DEFAULT_BUFFER_FOR_POLYGON_SEARCHES = 0

  attr_reader :radius

  def initialize(location, radius)
    @location = location
    @radius = get_radius(radius)
  end

  private

  attr_reader :location

  def get_radius(radius)
    return DEFAULT_BUFFER_FOR_POLYGON_SEARCHES unless location.present?

    if !location_polygon_search? && radius.to_s == DEFAULT_BUFFER_FOR_POLYGON_SEARCHES.to_s
      DEFAULT_RADIUS_FOR_POINT_SEARCHES
    else
      Integer(radius || default_radius).abs
    end
  end

  def default_radius
    location_polygon_search? ? DEFAULT_BUFFER_FOR_POLYGON_SEARCHES : DEFAULT_RADIUS_FOR_POINT_SEARCHES
  end

  def location_polygon_search?
    location.present? && LocationPolygon.include?(location)
  end
end
