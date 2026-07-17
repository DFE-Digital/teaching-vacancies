class OnsDataImport::Base
  # Security note: "ESMARspQHYMw9BZ9" looks like an API key, but it's just a service name
  # Hitting this URL gives a list f possible api_name values
  ARCGIS_BASE_URL = "https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/".freeze

  PER_PAGE = 20

  # The higher the value, the fewer vertices the polygon will have. Fewer vertices means less precision but faster.
  # In degrees, 0.001 is the equivalent to ~100m.
  # 0.001 provides a good balance between reducing the number of vertices and maintaining a precise shape for the
  # polygon (tested original vs simplified outputs in geojson.io).
  # EG: The original Cornwall polygon from ONS has 125k vertices, the simplified version with 0.001 tolerance has 2.5k
  # vertices, while retaining the same shape.
  TOLERANCE_100M = 0.001
  # SIMPLIFICATION_TOLERANCE = TOLERANCE_100M * 2.5

  class << self
    def call(api_name:, name_field:, valid_locations:, tolerance: TOLERANCE_100M)
      arcgis_features(client: faraday_client, name_field: name_field, api_name: api_name).select { |f|
        valid_locations.include?(f.fetch(:name))
      }.each do |feature|
        name = feature.fetch(:name)

        location_polygon = LocationPolygon.find_or_create_by!(name: name)
        type = LOCATIONS_MAPPED_TO_HUMAN_FRIENDLY_TYPES[name]
        geometry = feature.fetch(:geometry)

        # Rails.logger.info("Persisting new area data for '#{name}' (#{type}) tolerance #{tolerance}")
        # Our simplification runs make some areas invalid (east of england and norwich didn't work with 0.001)
        # so try progressively larger and larger simplifications until the areas are valid
        # Our simplification runs make some areas invalid (east of england and norwich didn't work with 0.001)
        # so try progressively larger and larger simplifications until the areas are valid
        0.upto(20).each do |tolerance_multiplier|
          new_tolerance = tolerance + (TOLERANCE_100M * tolerance_multiplier / 10.0)
          set_area_data(location_polygon, geometry, type, new_tolerance)
          set_uk_area_data(location_polygon, geometry, type, new_tolerance)
          location_polygon.touch
          location_polygon.reload
          if location_polygon.area_data_valid?
            Rails.logger.info("Persisted new area data for '#{name}' (#{type}) tolerance #{new_tolerance}")
            break
          end
        end
      end
    end

    private

    def faraday_client
      Faraday.new do |builder|
        builder.request :retry, {
          max: 2,
          interval: 0.05,
          interval_randomness: 0.5,
          backoff_factor: 2,
        }
        builder.use :http_cache, store: Rails.cache,
                                 logger: Rails.logger
        builder.adapter Faraday.default_adapter
        # builder.logger Rails.logger
        builder.response :json
        # builder.response :logger
        builder.response :raise_error
      end
    end

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
    def set_area_data(location_polygon, geometry, type, tolerance)
      ActiveRecord::Base.connection.exec_update("
      WITH geom AS (
        SELECT ST_MakeValid(
          ST_SimplifyPreserveTopology(
            ST_GeomFromGeoJSON(#{ActiveRecord::Base.connection.quote(geometry)}),
            #{tolerance}
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

    def set_uk_area_data(location_polygon, geometry_json, type, tolerance)
      # This is necessary as the ST_GeomFromGeoJSON() method that we would like to use
      # doesn't appear to support the optional 'srid' parameter that we need to pass
      geometry = RGeo::GeoJSON.decode(geometry_json)
      geometry_as_wkt = GeoFactories.convert_wgs84_to_sr27700(geometry).as_text
      ActiveRecord::Base.connection.exec_update("
      WITH geom AS (
        SELECT ST_MakeValid(
          ST_SimplifyPreserveTopology(
            ST_GeomFromText(#{ActiveRecord::Base.connection.quote(geometry_as_wkt)}, 27700),
            #{tolerance}
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

    def arcgis_features(client:, name_field:, api_name:)
      Enumerator.new do |yielder|
        (0..).each do |offset|
          # params = [
          #   "where=1%3D1",
          #   "outSR=4326",
          #   "f=pgeojson",
          #   "outFields=#{name_field}",
          #   "resultRecordCount=#{PER_PAGE}",
          #   "resultOffset=#{offset * PER_PAGE}",
          # ].join("&")
          params = {
            "where" => "1=1",
            "outSR" => "4326",
            "f" => "pgeojson",
            "outFields" => name_field,
            "resultRecordCount" => PER_PAGE,
            "resultOffset" => offset * PER_PAGE,
          }

          # response = HTTParty.get("#{ARCGIS_BASE_URL}#{api_name}/FeatureServer/0/query?#{params}")
          response = client.get "#{ARCGIS_BASE_URL}#{api_name}/FeatureServer/0/query", params
          # really hard to auto-test this, as it doesn't normally happen
          # :nocov:
          # raise "Unexpected ArcGIS response: #{response.code}" unless response.success?
          # :nocov:

          # response_data = JSON.parse(response.to_s)
          response_data = response.body
          raise "ArcGIS error: #{response_data['error']}" if response_data.key?("error")

          features = response_data.fetch("features")
          break if features.blank?

          features.each { |f| yielder << { name: f["properties"][name_field].downcase, geometry: f["geometry"].to_json } }
        end
      end
    end
  end
end
