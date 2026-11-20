class CreateGeocodedLocations < ActiveRecord::Migration[8.1]
  def change
    create_table :geocoded_locations, id: :uuid do |t|
      t.string :query, null: false
      t.float :latitude
      t.float :longitude
      t.datetime :geocoded_at, null: false

      t.timestamps
    end

    add_index :geocoded_locations, :query, unique: true
    add_index :geocoded_locations, :geocoded_at
  end
end
