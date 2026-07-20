module OnsDataImport
  class Import
    # Security note: "ESMARspQHYMw9BZ9" looks like an API key, but it's just a service name
    # Hitting this URL gives a list of possible api_name values
    # https://www.api.gov.uk/ons/open-geography-portal/#open-geography-portal
    # New portal coming soon https://alpha-ons-geoportal.hub.arcgis.com/
    # will have a cache time of 1 hour
    # https://alpha-ons-geoportal.hub.arcgis.com/datasets/affe59cd3aa54383a563f874f8a2334f_0/about
    # BFE	Full Extent – Full-resolution boundaries extend to the Extent of the Realm (Low Water Mark) and are the most detailed.
    # BFC	Full Clipped – Full-resolution boundaries clipped to the coastline (Mean High Water Mark).
    # BGC	Generalised Clipped – Generalised to 20 m and clipped to the coastline (Mean High Water Mark).
    # BSC	Super Generalised Clipped – Generalised to 200 m and clipped to the coastline (Mean High Water Mark).
    ARCGIS_BASE_URL = "https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/".freeze

    PER_PAGE = 20

    # The higher the value, the fewer vertices the polygon will have. Fewer vertices means less precision but faster.
    # In degrees, 0.001 is the equivalent to ~100m.
    # 0.001 provides a good balance between reducing the number of vertices and maintaining a precise shape for the
    # polygon (tested original vs simplified outputs in geojson.io).
    # EG: The original Cornwall polygon from ONS has 125k vertices, the simplified version with 0.001 tolerance has 2.5k
    # vertices, while retaining the same shape.
    SIMPLIFICATION_TOLERANCE = 0.001

    ArcGISFeature = Data.define(:name, :geometry)

    class << self
      def call(api_name:, name_field:, valid_locations:, tolerance:) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        if valid_locations.any?
          arcgis_features(client: faraday_client, name_field: name_field, api_name: api_name).select { |f|
            valid_locations.include?(f.name).tap do |included|
              Rails.logger.debug { "Skipping #{f.name}" } if !included && valid_locations.size > 10
            end
          }.each do |feature|
            location_polygon = LocationPolygon.find_or_create_by!(name: feature.name)
            type = LOCATIONS_MAPPED_TO_HUMAN_FRIENDLY_TYPES[feature.name]

            # Try progressively larger and larger simplifications until the areas are valid
            # because invalid areas are not useful at all.
            (0..).each do |tolerance_multiplier|
              new_tolerance = tolerance + (SIMPLIFICATION_TOLERANCE * tolerance_multiplier / 10.0)
              set_area_data(location_polygon, feature.geometry, type, new_tolerance)
              set_uk_area_data(location_polygon, feature.geometry, type, new_tolerance)
              location_polygon.touch
              location_polygon.reload
              # Need to keep importing with slightly greater tolerances until the data is valid.
              # Invalid polygons are worse than none because checking for validity at runtime is very expensive.
              # :nocov:
              if location_polygon.area_data_valid?
                Rails.logger.info("Persisted new area data for '#{feature.name}' (#{type}) tolerance #{new_tolerance}")
                break
              end
              # :nocov:
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
          builder.response :json
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
            params = {
              "where" => "1=1",
              "outSR" => "4326",
              "f" => "pgeojson",
              "outFields" => name_field,
              "resultRecordCount" => PER_PAGE,
              "resultOffset" => offset * PER_PAGE,
            }

            response = client.get "#{ARCGIS_BASE_URL}#{api_name}/FeatureServer/0/query", params

            response_data = response.body
            # :nocov:
            raise "ArcGIS error: #{response_data['error']}" if response_data.key?("error")
            # :nocov:

            features = response_data.fetch("features")
            break if features.blank?

            features.each { |f| yielder << ArcGISFeature.new(name: f.fetch("properties").fetch(name_field).downcase, geometry: f.fetch("geometry").to_json) }
          end
        end
      end
    end
  end
end
