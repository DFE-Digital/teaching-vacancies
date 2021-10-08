class AddIndexOnLocationPolygonName < ActiveRecord::Migration[6.1]
  def change
    add_index :location_polygons, :name
  end
end
