# Abstracts querying for a vacancy or organisation by location, should not be used directly
class LocationQuery < ApplicationQuery
  NATIONWIDE_LOCATIONS = ["england", "uk", "united kingdom", "britain", "great britain"].freeze

  attr_reader :scope

  include DistanceHelper

  private

  def call(field_name, location_query, radius_in_miles, polygon: nil, sort_by_distance: false)
    normalised_query = normalise_query(location_query)
    radius = convert_miles_to_metres(radius_in_miles.to_i)

    return scope if normalised_query.blank? || nationwide_location?(normalised_query)

    if polygon ||= LocationPolygon.with_name(normalised_query)
      handle_polygon_location(field_name, polygon, radius, sort_by_distance)
    else
      handle_coordinates(field_name, normalised_query, radius, sort_by_distance)
    end
  end

  def normalise_query(query)
    query&.strip&.downcase
  end

  def nationwide_location?(query)
    NATIONWIDE_LOCATIONS.include?(query)
  end

  def handle_polygon_location(field_name, polygon, radius, sort_by_distance)
    @scope = scope.joins("
      INNER JOIN location_polygons
      ON ST_DWithin(#{field_name}, location_polygons.area, #{radius}, false)
    ").where("location_polygons.id = ?", polygon.id)

    sort_by_polygon_distance(field_name) if sort_by_distance

    scope
  end

  def handle_coordinates(field_name, query, radius, sort_by_distance)
    coordinates = Geocoding.new(query).coordinates

    # TODO: Geocoding class currently returns this on error, it should probably raise a
    # suitable error instead. Refactor later!
    return scope.none if coordinates == [0, 0]

    point = "POINT(#{coordinates.second} #{coordinates.first})"
    @scope = scope.where("ST_DWithin(#{field_name}, ?, ?, false)", point, radius)

    sort_by_coordinates_distance(field_name, point) if sort_by_distance

    scope
  end

  def sort_by_polygon_distance(field_name)
    @scope = scope.select("vacancies.*, ST_Distance(#{field_name}, location_polygons.centroid, false) AS distance")
                  # why not using 'distance' alias? is not defined when calling this query with a 'pluck'
                  .order(Arel.sql("ST_Distance(#{field_name}, location_polygons.centroid, false)"))
  end

  def sort_by_coordinates_distance(field_name, point)
    @scope = scope.select("vacancies.*, ST_Distance(#{field_name}, '#{point}', false) AS distance")
                  # why not using 'distance' alias? is not defined when calling this query with a 'pluck'
                  .order(Arel.sql("ST_Distance(#{field_name}, '#{point}', false)"))
  end
end
