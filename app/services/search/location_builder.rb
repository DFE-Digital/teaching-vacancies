require "geocoding"

class Search::LocationBuilder
  DEFAULT_RADIUS = 10
  NATIONWIDE_LOCATIONS = ["england", "uk", "united kingdom", "britain", "great britain"].freeze

  include DistanceHelper

  attr_reader :location, :location_filter, :polygon_boundaries, :radius

  def initialize(location, radius)
    @location = location
    @radius = Integer(radius || DEFAULT_RADIUS).abs
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
    location_names = LocationPolygon.component_location_names(location) ||
                     [LocationPolygon.mapped_name(location)]
    locations = LocationPolygon.buffered(radius).where(name: location_names.map(&:downcase))

    @polygon_boundaries = locations.compact.flat_map(&:to_algolia_polygons)
  end

  def build_location_filter
    {
      point_coordinates: Geocoding.new(location).coordinates,
      radius: convert_miles_to_metres(radius),
    }
  end
end
