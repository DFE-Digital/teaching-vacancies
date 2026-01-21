module MapsHelper
  def vacancy_organisations_map_markers(vacancy)
    vacancy.organisations.filter_map do |organisation|
      if organisation.uk_geopoint?
        {
          id: vacancy.id,
          parent_id: organisation.id,
          geopoint: RGeo::GeoJSON.encode(GeoFactories.convert_sr27700_to_wgs84(organisation.uk_geopoint)).to_json,
        }
      end
    end
  end

  def organisation_map_marker(organisation)
    [
      {
        parent_id: organisation.id,
        geopoint: RGeo::GeoJSON.encode(GeoFactories.convert_sr27700_to_wgs84(organisation.uk_geopoint)).to_json,
      },
    ]
  end

  def organisation_map_can_be_displayed?(vacancy)
    return true unless vacancy.central_office?

    # :nocov:
    vacancy.organisation.uk_geopoint.present?
    # :nocov:
  end
end
