require "geocoding"

class Search::LocationBuilder
  DEFAULT_RADIUS = 10
  NATIONWIDE_LOCATIONS = ["england", "uk", "united kingdom", "britain", "great britain"].freeze

  include DistanceHelper

  attr_reader :location, :location_category, :location_filter,
              :location_polygon, :search_polygon_boundary, :missing_polygon, :radius, :buffer_radius

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
      initialize_nationwide_search
    elsif location_category_search?
      initialize_location_polygon
    elsif @location.present?
      @location_filter = build_location_filter(@location, @radius)
    end
  end

  def location_category_search?
    (@location_category && LocationCategory.include?(@location_category)) ||
      (@location && LocationCategory.include?(@location))
  end

  private

  def initialize_location_polygon
    @location_polygon = LocationPolygon.with_name(@location_category)
    if @location_polygon.present?
      @search_polygon_boundary = if @buffer_radius.present?
                                   [@location_polygon.buffers[@buffer_radius].first]
                                 else
                                   [@location_polygon.boundary]
                                 end
    end

    return unless location_polygon.nil? && (DOWNCASE_REGIONS + DOWNCASE_COUNTIES).include?(@location_category.downcase)

    # If a location category that we expect to have a polygon actually does not,
    # append the location category to the text search as a fallback.
    # This applies only to regions and counties: large areas for which there is
    # very little value in using a point coordinate, and for which there is a
    # low chance of ambiguity (unlike Clapham borough vs Clapham village in Bedfordshire)
    Rollbar.log(
      :error,
      "A location category search was performed as a text search as no LocationPolygon could
      be found with the name '#{@location_category}'.",
    )
    @missing_polygon = true
  end

  def build_location_filter(location, radius)
    {
      point_coordinates: Geocoding.new(location).coordinates,
      radius: convert_miles_to_metres(radius),
    }
  end

  def initialize_nationwide_search
    @location = nil
  end
end
