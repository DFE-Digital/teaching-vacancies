class OnsDataImport::Base
  # Security note: "ESMARspQHYMw9BZ9" looks like an API key, but it's just a service name
  ARCGIS_BASE_URL = "https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/".freeze

  PER_PAGE = 20

  def call
    (0..).each do |offset|
      response = HTTParty.get(arcgis_url(offset * PER_PAGE))
      raise "Unexpected ArcGIS response: #{response.code}" unless response.success?

      data = JSON.parse(response)
      break if data["features"].none?

      data["features"].each do |feature|
        name = feature["properties"][name_field].downcase
        next unless in_scope?(name)

        location_polygon = LocationPolygon.find_or_create_by(name: name)
        type = LOCATIONS_MAPPED_TO_HUMAN_FRIENDLY_TYPES[name]
        quoted_geometry = ActiveRecord::Base.connection.quote(feature["geometry"].to_json)
        quoted_type = ActiveRecord::Base.connection.quote(type)

        Rails.logger.info("Persisting new area data for '#{name}' (#{type})")
        ActiveRecord::Base.connection.exec_update("
          UPDATE location_polygons
          SET area=ST_GeomFromGeoJSON(#{quoted_geometry}),
              location_type=#{quoted_type}
          WHERE id='#{location_polygon.id}'
        ")
      end
    end
  end

  private

  def arcgis_url(offset)
    params = [
      "where=1%3D1",
      "outSR=4326",
      "f=pgeojson",
      "outFields=#{name_field}",
      "resultRecordCount=#{PER_PAGE}",
      "resultOffset=#{offset}",
    ].join("&")

    "#{ARCGIS_BASE_URL}#{api_name}/FeatureServer/0/query?#{params}"
  end
end
