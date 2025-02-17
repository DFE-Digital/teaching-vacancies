class OnsDataImport::CreateComposites
  def call
    DOWNCASE_COMPOSITE_LOCATIONS.each do |name, constituents|
      Rails.logger.info("Creating composite polygon for '#{name}'")

      composite = LocationPolygon.find_or_create_by(name: name)
      quoted_constituents = constituents.map { |c| ActiveRecord::Base.connection.quote(c.downcase) }

      ActiveRecord::Base.connection.exec_update("
        WITH composite_area AS (
          SELECT ST_SimplifyPreserveTopology(
            ST_Union(area::geometry),
            #{OnsDataImport::Base::SIMPLIFICATION_TOLERANCE})::geography AS geo
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
  end
end
