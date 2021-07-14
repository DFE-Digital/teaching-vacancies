class RemovePolygonsFromLocationPolygons < ActiveRecord::Migration[6.1]
  def change
    remove_column :location_polygons, :polygons, :jsonb
  end
end
