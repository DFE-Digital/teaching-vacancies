require "geocoding"

class Search::LocationBuilder
  DEFAULT_RADIUS_FOR_POINT_SEARCHES = 10
  DEFAULT_BUFFER_FOR_POLYGON_SEARCHES = 0
  NATIONWIDE_LOCATIONS = ["england", "uk", "united kingdom", "britain", "great britain"].freeze

  include DistanceHelper

  attr_reader :location, :location_filter, :polygon_boundaries, :radius

  def initialize(location, radius)
    @location = location
    @radius = get_radius(radius)
    @location_filter = {}

    if NATIONWIDE_LOCATIONS.include?(@location&.downcase)
      @location = nil
    elsif search_with_polygons?
      initialize_polygon_boundaries
    elsif @location.present?
      @location_filter = build_location_filter
    end
  end

  def search_with_polygons?
    location.present? && LocationPolygon.include?(location)
  end

  def point_coordinates
    location_filter[:point_coordinates]
  end

  private

  def initialize_polygon_boundaries
    @polygon_boundaries = LocationPolygon.buffered(radius).with_name(location).to_algolia_polygons
  end

  def build_location_filter
    {
      point_coordinates: Geocoding.new(location).coordinates,
      radius: convert_miles_to_metres(radius),
    }
  end

  def get_radius(radius)
    return DEFAULT_BUFFER_FOR_POLYGON_SEARCHES unless location.present?

    if !search_with_polygons? && radius.to_s == DEFAULT_BUFFER_FOR_POLYGON_SEARCHES.to_s
      DEFAULT_RADIUS_FOR_POINT_SEARCHES
    else
      Integer(radius || default_radius).abs
    end
  end

  def default_radius
    search_with_polygons? ? DEFAULT_BUFFER_FOR_POLYGON_SEARCHES : DEFAULT_RADIUS_FOR_POINT_SEARCHES
  end
end
