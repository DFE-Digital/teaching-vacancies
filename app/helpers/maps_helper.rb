module MapsHelper
  def organisation_map_markers(vacancy)
    vacancy.organisations.map do |organisation|
      {
        geopoint: organisation.geopoint,
        heading: map_link(organisation.name, organisation.url, vacancy_id: vacancy.id),
        description: organisation_type(organisation),
        address: full_address(organisation),
      }
    end
  end
end
