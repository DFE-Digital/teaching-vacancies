class Search::RadiusBuilder
  DEFAULT_RADIUS_FOR_POINT_SEARCHES = 10
  DEFAULT_BUFFER_FOR_POLYGON_SEARCHES = 0
  DEFAULT_RADIUS_FOR_JOB_ALERT_V2 = 15

  attr_reader :radius, :polygon

  def initialize(location, radius)
    @location = location
    @polygon = LocationPolygon.with_name(location) if location.present?
    @radius = get_radius(radius)
  end

  private

  attr_reader :location

  def get_radius(radius)
    if (radius == "v2_default")
      DEFAULT_RADIUS_FOR_JOB_ALERT_V2
    elsif location.blank?
      DEFAULT_BUFFER_FOR_POLYGON_SEARCHES
    elsif polygon.blank? && radius.to_s == DEFAULT_BUFFER_FOR_POLYGON_SEARCHES.to_s
      DEFAULT_RADIUS_FOR_POINT_SEARCHES
    else
      Integer(radius || default_radius).abs
    end
  end

  def default_radius
    polygon.present? ? DEFAULT_BUFFER_FOR_POLYGON_SEARCHES : DEFAULT_RADIUS_FOR_POINT_SEARCHES
  end
end
