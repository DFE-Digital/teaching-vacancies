class AddUsageCountToLocationPolygons < ActiveRecord::Migration[6.0]
  def change
    add_column :location_polygons, :usage_count, :integer, default: 0
  end
end
