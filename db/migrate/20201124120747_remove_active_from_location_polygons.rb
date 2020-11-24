class RemoveActiveFromLocationPolygons < ActiveRecord::Migration[6.0]
  def change
    remove_column :location_polygons, :active, :boolean
  end
end
