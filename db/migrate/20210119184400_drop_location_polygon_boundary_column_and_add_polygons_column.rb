class DropLocationPolygonBoundaryColumnAndAddPolygonsColumn < ActiveRecord::Migration[6.1]
  def change
    remove_column :location_polygons, :boundary
    add_column :location_polygons, :polygons, :jsonb
  end
end
