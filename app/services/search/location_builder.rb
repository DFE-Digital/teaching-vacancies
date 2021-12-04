require "geocoding"

class Search::LocationBuilder
  NATIONWIDE_LOCATIONS = ["england", "uk", "united kingdom", "britain", "great britain"].freeze

  include DistanceHelper

  attr_reader :location, :location_filter, :polygon_boundaries, :radius

  def initialize(location, radius)
    @location = location
    @radius = Search::RadiusBuilder.new(location, radius).radius
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
end
