class AddBuffersToLocationPolygons < ActiveRecord::Migration[6.0]
  def change
    add_column :location_polygons, :buffers, :jsonb
  end
end
