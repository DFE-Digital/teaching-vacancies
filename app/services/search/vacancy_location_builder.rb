class Search::VacancyLocationBuilder
  DEFAULT_RADIUS = 10
  MILES_TO_METRES = 1.60934 * 1000

  attr_reader :location, :location_category, :location_filter,
              :location_polygon, :missing_polygon, :user_input_polygon

  def initialize(location, radius, location_category, user_input_polygon)
    @location = location || location_category
    @radius = (radius || DEFAULT_RADIUS).to_i
    @location_filter = {}

    @location_category = if @location.present? && LocationCategory.include?(@location)
                           @location
                         else
                           location_category
                         end

    @user_input_polygon = user_input_polygon.present? ? [user_input_polygon.map(&:to_f)] : nil

    if user_input_polygon_search?
      @location = nil
      @location_category = nil
    end

    if location_category_search?
      initialize_location_polygon
    elsif @location.present?
      @location_filter = build_location_filter(@location, @radius)
    end
  end

  def location_category_search?
    (@location_category && LocationCategory.include?(@location_category)) ||
        (@location && LocationCategory.include?(@location))
  end

  def user_input_polygon_search?
    @user_input_polygon.present?
  end

  def polygon_coordinates
    user_input_polygon_search? ? @user_input_polygon : @location_polygon_boundary
  end

  private

  def initialize_location_polygon
    @location_polygon = LocationPolygon.with_name(@location_category)
    @location_polygon_boundary = [@location_polygon.boundary] if @location_polygon.present?
    if location_polygon.nil? && (DOWNCASE_REGIONS + DOWNCASE_COUNTIES).include?(@location_category.downcase)
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
  end

  def build_location_filter(location, radius)
    { point_coordinates: Geocoding.new(location).coordinates, radius: convert_radius_in_miles_to_metres(radius) }
  end

  def convert_radius_in_miles_to_metres(radius)
    (radius * MILES_TO_METRES).to_i
  end
end
