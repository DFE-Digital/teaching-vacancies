class OnsDataImport::CreateComposites
  class << self
    def call(tolerance: OnsDataImport::Import::SIMPLIFICATION_TOLERANCE)
      DOWNCASE_COMPOSITE_LOCATIONS.map { |n, c| [n, c.map(&:downcase)] }.each do |name, constituents|
        location_polygon = LocationPolygon.find_or_create_by!(name: name)

        quoted_constituents = constituents.map { |c| ActiveRecord::Base.connection.quote(c) }
        # devon, plymouth and torbay didn't cope with the default tolerance

        (0..).each do |tolerance_multiplier|
          new_tolerance = tolerance + (OnsDataImport::Import::SIMPLIFICATION_TOLERANCE * tolerance_multiplier / 2.0)

          OnsDataImport::ImportCities.call(tolerance: new_tolerance, valid_locations: constituents)
          OnsDataImport::ImportCounties.call(tolerance: new_tolerance, valid_locations: constituents)

          set_area_data(location_polygon, quoted_constituents, new_tolerance)
          set_uk_area_data(location_polygon, quoted_constituents, new_tolerance)
          location_polygon.touch
          location_polygon.reload
          # simplecov:disable
          if location_polygon.area_data_valid?
            Rails.logger.info("Created composite polygon for '#{name}' tolerance #{new_tolerance}")
            break
          end
          # simplecov:enable
        end
      end
    end

    private

    def set_area_data(composite, quoted_constituents, tolerance)
      ActiveRecord::Base.connection.exec_update("
      WITH composite_area AS (
        SELECT ST_MakeValid(
          ST_SimplifyPreserveTopology(
            ST_Union(area::geometry),
            #{tolerance}
          ),
          'method=structure'
        )::geography AS geo
        FROM location_polygons
        WHERE name IN (#{quoted_constituents.join(', ')})
      )
      UPDATE location_polygons
      SET area=composite_area.geo,
          location_type='composite',
          centroid=ST_Centroid(composite_area.geo)
      FROM composite_area
      WHERE id='#{composite.id}'
    ")
    end

    def set_uk_area_data(composite, quoted_constituents, tolerance)
      ActiveRecord::Base.connection.exec_update("
      WITH composite_area AS (
        SELECT ST_MakeValid(
          ST_SimplifyPreserveTopology(
            ST_Union(uk_area::geometry),
            #{tolerance}
          ),
          'method=structure'
        )::geometry AS geo
        FROM location_polygons
        WHERE name IN (#{quoted_constituents.join(', ')})
      )
      UPDATE location_polygons
      SET uk_area=composite_area.geo,
          location_type='composite',
          uk_centroid=ST_Centroid(composite_area.geo)
      FROM composite_area
      WHERE id='#{composite.id}'
    ")
    end
  end
end
