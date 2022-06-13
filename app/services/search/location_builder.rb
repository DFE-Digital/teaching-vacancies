require "geocoding"

class Search::LocationBuilder
  NATIONWIDE_LOCATIONS = ["england", "uk", "united kingdom", "britain", "great britain"].freeze

  include DistanceHelper

  attr_reader :location, :radius, :travel_time, :transportation_type, :commute_area, :location_polygon, :radius_area

  def initialize(location, radius, travel_time, transportation_type)
    @location = location unless nationwide_search?(location)
    @radius = Search::RadiusBuilder.new(location, radius).radius
    @travel_time = travel_time
    @transportation_type = transportation_type
    set_commute_area if commute_area_search?
    set_location_polygon if location_polygon_search?
    set_radius_area if radius_search?
  end

  def nationwide_search?(location)
    NATIONWIDE_LOCATIONS.include?(location&.downcase)
  end

  def radius_search?
    location && !location_polygon_search? && !commute_area_search?
  end

  def location_polygon_search?
    location && LocationPolygon.include?(location)
  end

  def commute_area_search?
    location && transportation_type && travel_time
  end

  def point_coordinates
    @point_coordinates ||= Geocoding.new(location).coordinates
  end

  def point
    @point ||= RGeo::GeoJSON.encode(factory_point)
  end

  def area
    commute_area || location_polygon&.area || radius_area
  end

  def polygon
    @polygon ||= RGeo::GeoJSON.encode(area)
  end

  def radius_in_meters
    convert_miles_to_metres(radius)
  end

  private

  def set_radius_area
    @radius_area = factory_point.buffer(radius_in_meters)
  end

  def set_commute_area
    @commute_area = TravelTime.new(location, transportation_type, travel_time).commute_area
  end

  def set_location_polygon
    @location_polygon = LocationPolygon.buffered(radius).with_name(location)
  end

  def factory_point
    @factory_point ||= factory.point(*point_coordinates.reverse)
  end

  def factory
    @factory ||= RGeo::ActiveRecord::SpatialFactoryStore.instance.default
  end
end
