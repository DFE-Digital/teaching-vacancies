class RemoveLegacyBuffersFromLocationPolygons < ActiveRecord::Migration[6.1]
  def change
    remove_column :location_polygons, :buffers
  end
end
