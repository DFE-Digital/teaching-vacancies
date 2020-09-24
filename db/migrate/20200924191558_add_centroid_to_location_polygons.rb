class AddCentroidToLocationPolygons < ActiveRecord::Migration[6.0]
  def change
    add_column :location_polygons, :centroid, :point
  end
end
