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

  def organisation_map_can_be_displayed?(vacancy)
    return true unless vacancy.central_office?

    vacancy.organisation.geopoint.present?
  end
end
