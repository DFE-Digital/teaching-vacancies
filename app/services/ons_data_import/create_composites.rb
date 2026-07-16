class OnsDataImport::CreateComposites
  class << self
    def call(tolerance)
      DOWNCASE_COMPOSITE_LOCATIONS.each do |name, constituents|
        location_polygon = LocationPolygon.find_or_create_by(name: name)
        quoted_constituents = constituents.map { |c| ActiveRecord::Base.connection.quote(c.downcase) }
        # devon, plymouth and torbay didn't cope with the default tolerance

        0.upto(10).each do |tolerance_multiplier|
          new_tolerance = tolerance + (OnsDataImport::Base::TOLERANCE_100M * tolerance_multiplier / 10.0)

          set_area_data(location_polygon, quoted_constituents, new_tolerance)
          set_uk_area_data(location_polygon, quoted_constituents, new_tolerance)
          location_polygon.touch
          location_polygon.reload
          begin
            if location_polygon.area.invalid_reason.nil? && location_polygon.uk_area.invalid_reason.nil?
              Rails.logger.info("Created composite polygon for '#{name}' tolerance #{new_tolerance}")
              break
            end
          rescue StandardError
            false
          end
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
