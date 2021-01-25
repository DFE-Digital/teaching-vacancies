class DeleteDuplicateLocationPolygons < ActiveRecord::Migration[6.1]
  def change
    LocationPolygon.where(polygons: nil).delete_all
  end
end
