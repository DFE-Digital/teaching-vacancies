class OnsDataImport::Base
  # Security note: "ESMARspQHYMw9BZ9" looks like an API key, but it's just a service name
  ARCGIS_BASE_URL = "https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/".freeze

  PER_PAGE = 20

  def call
    (0..).each do |offset|
      features = arcgis_features(offset)
      break if features.none?

      features.each do |feature|
        name = feature["properties"][name_field].downcase
        next unless in_scope?(name)

        location_polygon = LocationPolygon.find_or_create_by(name: name)
        type = LOCATIONS_MAPPED_TO_HUMAN_FRIENDLY_TYPES[name]
        geometry = feature["geometry"].to_json

        Rails.logger.info("Persisting new area data for '#{name}' (#{type})")
        ActiveRecord::Base.connection.exec_update("
          UPDATE location_polygons
          SET area=ST_GeomFromGeoJSON(#{ActiveRecord::Base.connection.quote(geometry)}),
              location_type=#{ActiveRecord::Base.connection.quote(type)}
          WHERE id='#{location_polygon.id}'
        ")
      end
    end
  end

  private

  def arcgis_features(offset)
    params = [
      "where=1%3D1",
      "outSR=4326",
      "f=pgeojson",
      "outFields=#{name_field}",
      "resultRecordCount=#{PER_PAGE}",
      "resultOffset=#{offset * PER_PAGE}",
    ].join("&")

    response = HTTParty.get("#{ARCGIS_BASE_URL}#{api_name}/FeatureServer/0/query?#{params}")
    raise "Unexpected ArcGIS response: #{response.code}" unless response.success?

    JSON.parse(response)["features"]
  end
end
