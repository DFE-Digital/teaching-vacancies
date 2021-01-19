require "geocoding"

class Search::LocationBuilder
  DEFAULT_RADIUS = 10
  NATIONWIDE_LOCATIONS = ["england", "uk", "united kingdom", "britain", "great britain"].freeze

  include DistanceHelper

  attr_reader :location, :location_category, :location_filter, :polygon_boundaries, :radius, :buffer_radius

  def initialize(location, radius, location_category, buffer_radius)
    @location = location || location_category
    @radius = (radius || DEFAULT_RADIUS).to_i
    @buffer_radius = buffer_radius
    @location_filter = {}
    @location_category = if @location.present? && LocationCategory.include?(@location)
                           @location
                         else
                           location_category
                         end

    if NATIONWIDE_LOCATIONS.include?(@location&.downcase)
      @location = nil
    elsif location_category_search?
      initialize_polygon_boundaries
    elsif @location.present?
      @location_filter = build_location_filter(@location, @radius)
    end
  end

  def location_category_search?
    (location_category && LocationCategory.include?(location_category)) ||
      (location && LocationCategory.include?(location))
  end

  private

  def initialize_polygon_boundaries
    locations = [LocationPolygon.with_name(location_category)]

    if locations.none? && DOWNCASE_COMPOSITE_LOCATIONS.key?(location_category.downcase)
      locations = DOWNCASE_COMPOSITE_LOCATIONS[location_category.downcase].map do |component_location_name|
        LocationPolygon.find_by(name: component_location_name.downcase)
      end
    end

    @polygon_boundaries = []
    locations.each do |location|
      polygons = buffer_radius.present? ? location.buffers[buffer_radius] : location.polygons.values
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
