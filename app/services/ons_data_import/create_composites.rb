class OnsDataImport::CreateComposites
  def call
    DOWNCASE_COMPOSITE_LOCATIONS.each do |name, constituents|
      Rails.logger.info("Creating composite polygon for '#{name}'")

      composite = LocationPolygon.find_or_create_by(name:)
      quoted_constituents = constituents.map { |c| ActiveRecord::Base.connection.quote(c.downcase) }

      ActiveRecord::Base.connection.exec_update("
        UPDATE location_polygons
        SET area=(
              SELECT ST_Union(area::geometry)::geography
              FROM location_polygons
              WHERE name IN (#{quoted_constituents.join(', ')})
            ),
            location_type='composite'
        WHERE id='#{composite.id}'
      ")
    end
  end
end
