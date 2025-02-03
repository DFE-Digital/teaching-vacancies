class AddCentroidToLocationPolygons < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_column :location_polygons, :centroid, :st_point, geographic: true
    add_index :location_polygons, :centroid, using: :gist, algorithm: :concurrently
  end
end
