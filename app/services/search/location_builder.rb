require "geocoding"

class Search::LocationBuilder
  NATIONWIDE_LOCATIONS = ["england", "uk", "united kingdom", "britain", "great britain"].freeze

  include DistanceHelper

  attr_reader :location, :location_filter, :polygon, :radius

  def initialize(location, radius)
    @radius_builder = Search::RadiusBuilder.new(location, radius)
    @location = location
    @radius = @radius_builder.radius
    @location_filter = {}

    if NATIONWIDE_LOCATIONS.include?(@location&.downcase)
      @location = nil
    elsif @radius_builder.polygon.present?
      @polygon = LocationPolygon.buffered(@radius).with_name(location)
    elsif @location.present?
      @location_filter = build_location_filter
    end
  end

  def point_coordinates
    location_filter[:point_coordinates]
  end

  def radius_in_meters
    location_filter[:radius]
  end

  private

  def build_location_filter
    {
      point_coordinates: Geocoding.new(location).coordinates,
      radius: convert_miles_to_metres(radius),
    }
  end
end
