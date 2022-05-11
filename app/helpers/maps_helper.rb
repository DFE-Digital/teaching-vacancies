module MapsHelper
  def vacancy_map_markers(vacancies, polygon, coordinates, radius)
    organisation_ids = Organisation.in_vacancy_ids(vacancies.pluck(:id))
                                   .within_polygon(polygon)
                                   .within_area(coordinates, radius)
                                   .pluck(:id)

    vacancies.map { |vacancy|
      vacancy.organisations.select { |organisation| organisation.id.in?(organisation_ids) }.map do |organisation|
        {
          id: vacancy.id,
          parent_id: organisation.id,
          geopoint: RGeo::GeoJSON.encode(organisation.geopoint),
        }
      end
    }.flatten
  end

  def organisation_map_markers(vacancy)
    vacancy.organisations.map do |organisation|
      {
        id: vacancy.id,
        parent_id: organisation.id,
        geopoint: RGeo::GeoJSON.encode(organisation.geopoint),
      }
    end
  end
end
