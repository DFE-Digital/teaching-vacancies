class AddPolygonsColumnToLocationPolygons < ActiveRecord::Migration[6.1]
  def change
    add_column :location_polygons, :polygons, :jsonb
  end
end
