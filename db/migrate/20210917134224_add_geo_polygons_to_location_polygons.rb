class AddGeoPolygonsToLocationPolygons < ActiveRecord::Migration[6.1]
  def change
    add_column :location_polygons, :area, :geometry, geographic: true
    add_index :location_polygons, :area, using: :gist
  end
end
