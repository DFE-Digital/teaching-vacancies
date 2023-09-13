# Abstracts querying for a vacancy or organisation by location, should not be used directly
class LocationQuery < ApplicationQuery
  NATIONWIDE_LOCATIONS = ["england", "uk", "united kingdom", "britain", "great britain"].freeze

  attr_reader :scope

  include DistanceHelper

  private

  def call(field_name, location_query, radius_in_miles, sort_by_distance)
    normalised_query = location_query&.strip&.downcase
    radius = convert_miles_to_metres(radius_in_miles.to_i)

    if normalised_query.blank? || NATIONWIDE_LOCATIONS.include?(normalised_query)
      return scope
    elsif LocationPolygon.contain?(normalised_query)
      polygon = LocationPolygon.with_name(normalised_query)
      query = scope.joins("
        INNER JOIN location_polygons
        ON ST_DWithin(#{field_name}, location_polygons.area, #{radius})
      ").where("location_polygons.id = ?", polygon.id)

      if sort_by_distance
        query = query.select("vacancies.*, ST_Distance(#{field_name}, ST_Centroid(location_polygons.area)) AS distance")
                     .order(Arel.sql("ST_Distance(#{field_name}, ST_Centroid(location_polygons.area))"))
      end
      
      return query
    else
      coordinates = Geocoding.new(normalised_query).coordinates
  
      # TODO: Geocoding class currently returns this on error, it should probably raise a
      # suitable error instead. Refactor later!
      return scope.none if coordinates == [0, 0]
  
      point = "POINT(#{coordinates.second} #{coordinates.first})"

      query = scope.where("ST_DWithin(#{field_name}, ?, ?)", point, radius)
      if sort_by_distance
        query = query.select("vacancies.*, ST_Distance(#{field_name}, '#{point}') AS distance")
                     .order(Arel.sql("ST_Distance(#{field_name}, '#{point}')"))
      end

      return query
    end  
  end
end
