class OnsDataImport::Base
  # Security note: "ESMARspQHYMw9BZ9" looks like an API key, but it's just a service name
  ARCGIS_BASE_URL = "https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/".freeze

  PER_PAGE = 20

  # The higher the value, the less vertices the polygon will have. Less vertices means less precision but faster.
  # In degrees, 0.001 is the equivalent to ~100m.
  # 0.001 provides a good balance between reducing the number of vertices and maintaining a precise shape for the
  # polygon (tested original vs simplified outputs in geojson.io).
  # EG: The original Cornwall polygon from ONS has 125k vertices, the simplified version with 0.001 tolerance has 2.5k
  # vertices, while retaining the same shape.
  SIMPLIFICATION_TOLERANCE = 0.001

  class << self
    def call(api_name:, name_field:, valid_locations:)
      (0..).each do |offset|
        features = arcgis_features(offset: offset, name_field: name_field, api_name: api_name)
        break if features.blank?

        features.each do |feature|
          name = feature["properties"][name_field].downcase
          next unless valid_locations.include?(name)

          location_polygon = LocationPolygon.find_or_create_by(name: name)
          type = LOCATIONS_MAPPED_TO_HUMAN_FRIENDLY_TYPES[name]
          geometry = feature["geometry"].to_json

          Rails.logger.info("Persisting new area data for '#{name}' (#{type})")
          set_area_data(location_polygon, geometry, type)
          set_uk_area_data(location_polygon, geometry, type)
        end
      end
    end

    private

    # Sets the area, location type and centroid for a location polygon coming from the ONS API.
    #
    # "ST_SimplifyPreserveTopology" is used to reduce the number of vertices in the polygon while ensuring the resulting
    # polygon is topologically equivalent to the original.
    # This simplification is important because the ONS API returns polygons with a large number of vertices,
    # which makes ST_Buffer operations very computationally expensive.
    #
    # The "ST_MakeValid" attempts to fix any resulting invalid area prior to store it.
    # Rhe 'method=structure' parameter builds the new geometry by unioning exterior rings resulting into a single
    # non-overlapping polygon
    #
    # The area centroid is precomputed and stored to avoid recomputing it every time it's needed.
    def set_area_data(location_polygon, geometry, type)
      ActiveRecord::Base.connection.exec_update("
      WITH geom AS (
        SELECT ST_MakeValid(
          ST_SimplifyPreserveTopology(
            ST_GeomFromGeoJSON(#{ActiveRecord::Base.connection.quote(geometry)}),
            #{SIMPLIFICATION_TOLERANCE}
          ),
          'method=structure'
        )::geography AS geo
      )
      UPDATE location_polygons
      SET area=geom.geo,
          location_type=#{ActiveRecord::Base.connection.quote(type)},
          centroid=ST_Centroid(geom.geo)
      FROM geom
      WHERE id='#{location_polygon.id}'
    ")
    end

    def set_uk_area_data(location_polygon, geometry_json, type)
      # This is necessary as the ST_GeomFromGeoJSON() method that we would like to use
      # doesn't appear to support the optional 'srid' parameter that we need to pass
      geometry = RGeo::GeoJSON.decode(geometry_json)
      geometry_as_wkt = GeoFactories.convert_wgs84_to_sr27700(geometry).as_text
      ActiveRecord::Base.connection.exec_update("
      WITH geom AS (
        SELECT ST_MakeValid(
          ST_SimplifyPreserveTopology(
            ST_GeomFromText(#{ActiveRecord::Base.connection.quote(geometry_as_wkt)}, 27700),
            #{SIMPLIFICATION_TOLERANCE}
          ),
          'method=structure'
        )::geometry AS geo
      )
      UPDATE location_polygons
      SET uk_area=geom.geo,
          location_type=#{ActiveRecord::Base.connection.quote(type)},
          uk_centroid=ST_Centroid(geom.geo)
      FROM geom
      WHERE id='#{location_polygon.id}'
    ")
    end

    def arcgis_features(offset:, name_field:, api_name:)
      params = [
        "where=1%3D1",
        "outSR=4326",
        "f=pgeojson",
        "outFields=#{name_field}",
        "resultRecordCount=#{PER_PAGE}",
        "resultOffset=#{offset * PER_PAGE}",
      ].join("&")

      response = HTTParty.get("#{ARCGIS_BASE_URL}#{api_name}/FeatureServer/0/query?#{params}")
      # really hard to auto-test this, as it doesn't normally happen
      # :nocov:
      raise "Unexpected ArcGIS response: #{response.code}" unless response.success?
      # :nocov:

      response_data = JSON.parse(response.to_s)
      raise "ArcGIS error: #{response_data['error']}" if response_data.key?("error")

      response_data.fetch("features")
    end
  end
end
