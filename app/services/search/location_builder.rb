require "geocoding"

class Search::LocationBuilder
  DEFAULT_RADIUS_FOR_POINT_SEARCHES = 10
  DEFAULT_BUFFER_FOR_POLYGON_SEARCHES = 0
  NATIONWIDE_LOCATIONS = ["england", "uk", "united kingdom", "britain", "great britain"].freeze

  include DistanceHelper

  attr_reader :location, :radius, :travel_time, :transportation_type, :location_polygon

  def initialize(location, radius, travel_time, transportation_type)
    @location = location&.strip&.downcase
    @travel_time = travel_time
    @transportation_type = transportation_type
    set_radius(radius)
    set_commute_area if commute_area_search?
    set_location_polygon if location_polygon_search?
    set_radius_area if radius_search?
  end

  def valid_location_search?
    location && !NATIONWIDE_LOCATIONS.include?(location)
  end

  def commute_area_search?
    valid_location_search? && transportation_type && travel_time
  end

  def location_polygon_search?
    valid_location_search? && LocationPolygon.include?(location)
  end

  def radius_search?
    valid_location_search? && !location_polygon_search? && !commute_area_search?
  end

  def point_coordinates
    @point_coordinates ||= Geocoding.new(location).coordinates
  end

  def point
    @point ||= RGeo::GeoJSON.encode(factory_point)
  end

  def area
    @commute_area || @location_polygon&.area || @radius_area
  end

  def polygon
    @polygon ||= RGeo::GeoJSON.encode(area)
  end

  private

  def set_radius(radius)
    @radius =
      if radius_search? && radius.to_i == DEFAULT_BUFFER_FOR_POLYGON_SEARCHES
        DEFAULT_RADIUS_FOR_POINT_SEARCHES
      else
        Integer(radius || default_radius).abs
      end
  end

  def default_radius
    location_polygon_search? ? DEFAULT_BUFFER_FOR_POLYGON_SEARCHES : DEFAULT_RADIUS_FOR_POINT_SEARCHES
  end

  def set_commute_area
    @commute_area = TravelTime.new(location, transportation_type, travel_time).commute_area
  end

  def set_location_polygon
    @location_polygon = LocationPolygon.buffered(radius).with_name(location)
  end

  def set_radius_area
    @radius_area = factory_point.buffer(radius_in_meters)
  end

  def radius_in_meters
    convert_miles_to_metres(radius)
  end

  def factory_point
    @factory_point ||= factory.point(*point_coordinates.reverse)
  end

  def factory
    @factory ||= RGeo::ActiveRecord::SpatialFactoryStore.instance.default
  end
end
