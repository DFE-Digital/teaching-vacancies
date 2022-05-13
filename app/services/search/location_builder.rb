require "geocoding"

class Search::LocationBuilder
  NATIONWIDE_LOCATIONS = ["england", "uk", "united kingdom", "britain", "great britain"].freeze

  include DistanceHelper

  attr_reader :location, :location_filter, :polygon, :radius

  def initialize(location, radius)
    @location = location
    @radius = Search::RadiusBuilder.new(location, radius).radius
    @location_filter = {}

    if NATIONWIDE_LOCATIONS.include?(@location&.downcase)
      @location = nil
    elsif search_with_polygons?
      @polygon = LocationPolygon.buffered(@radius).with_name(location)
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

  def radius_in_meters
    location_filter[:radius]
  end

  def geojson_point
    return unless location_filter[:point_coordinates]

    RGeo::GeoJSON.encode(factory.point(*location_filter[:point_coordinates].reverse))
  end

  def geojson_polygon
    RGeo::GeoJSON.encode(polygon&.area)
  end

  private

  def build_location_filter
    {
      point_coordinates: Geocoding.new(location).coordinates,
      radius: convert_miles_to_metres(radius),
    }
  end

  def factory
    @factory ||= RGeo::ActiveRecord::SpatialFactoryStore.instance.default
  end
end
