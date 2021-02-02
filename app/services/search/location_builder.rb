require "geocoding"

class Search::LocationBuilder
  DEFAULT_RADIUS = 10
  NATIONWIDE_LOCATIONS = ["england", "uk", "united kingdom", "britain", "great britain"].freeze

  include DistanceHelper

  attr_reader :buffer_radius, :location, :location_filter, :polygon_boundaries, :radius

  def initialize(location, radius, buffer_radius)
    @location = location
    @radius = (radius || DEFAULT_RADIUS).to_i
    @buffer_radius = buffer_radius
    @location_filter = {}

    if NATIONWIDE_LOCATIONS.include?(@location&.downcase)
      @location = nil
    elsif search_with_polygons?
      initialize_polygon_boundaries
    elsif @location.present?
      @location_filter = build_location_filter(@location, @radius)
    end
  end

  def search_with_polygons?
    location && LocationPolygon.include?(location)
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
    locations.each do |location|
      polygons = buffer_radius.present? ? location.buffers[buffer_radius] : location.polygons["polygons"]
      polygons.each do |polygon|
        @polygon_boundaries.push(polygon)
      end
    end
  end

  def build_location_filter(location, radius)
    {
      point_coordinates: Geocoding.new(location).coordinates,
      radius: convert_miles_to_metres(radius),
    }
  end
end
