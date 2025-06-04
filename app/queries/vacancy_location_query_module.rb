# frozen_string_literal: true

module VacancyLocationQueryModule
  def vacancy_location_query(location_query, radius_in_miles, polygon:, sort_by_distance:)
    VacancyLocationQuery.new(all).call(location_query, radius_in_miles, polygon: polygon, sort_by_distance: sort_by_distance)
  end
end
