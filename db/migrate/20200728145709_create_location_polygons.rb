class CreateLocationPolygons < ActiveRecord::Migration[5.2]
  def change
    create_table :location_polygons, id: :uuid do |t|
      t.string :name, null: false
      t.string :location_type
      t.float :boundary, array: true
      t.boolean :active
      t.timestamps
    end
  end
end
