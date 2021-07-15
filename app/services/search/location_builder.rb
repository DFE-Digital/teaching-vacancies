require "geocoding"

class Search::LocationBuilder
  DEFAULT_RADIUS = 10
  NATIONWIDE_LOCATIONS = ["england", "uk", "united kingdom", "britain", "great britain"].freeze

  include DistanceHelper

  attr_reader :location, :location_filter, :polygon_boundaries, :radius

  def initialize(location, radius)
    @location = location
    @radius = (radius || DEFAULT_RADIUS).to_i
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
    location && LocationPolygon.include?(location)
  end

  def point_coordinates
    location_filter[:point_coordinates]
  end

  private

  def initialize_polygon_boundaries
    locations = [LocationPolygon.with_name(location)]

    if locations.none? && LocationPolygon.composite?(location)
      locations = LocationPolygon.component_location_names(location).map do |component_location_name|
        LocationPolygon.find_by(name: component_location_name.downcase)
      end
    end

    @polygon_boundaries = []
    locations.compact.each do |location|
      polygons = location.buffers[radius.to_s]
      polygons.each do |polygon|
        @polygon_boundaries.push(polygon)
      end
    end
  end

  def build_location_filter
    {
      point_coordinates: build_coordinates,
      radius: convert_miles_to_metres(radius),
    }
  end

  def build_coordinates
    if location.respond_to?(:x)
      [location.x, location.y]
    else
      Geocoding.new(location).coordinates
    end
  end
end
