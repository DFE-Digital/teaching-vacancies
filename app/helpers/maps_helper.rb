module MapsHelper
  def organisation_map_markers(vacancy)
    vacancy.organisations.map do |organisation|
      {
        id: vacancy.id,
        parent_id: organisation.id,
        geopoint: RGeo::GeoJSON.encode(organisation.geopoint)&.to_json,
      }
    end
  end
end
