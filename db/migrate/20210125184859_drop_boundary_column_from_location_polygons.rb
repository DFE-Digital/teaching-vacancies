class DropBoundaryColumnFromLocationPolygons < ActiveRecord::Migration[6.1]
  def change
    remove_column :location_polygons, :boundary
  end
end
