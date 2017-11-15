class AddEastingNorthingGeolocationToSchools < ActiveRecord::Migration[5.1]
  def change
    add_column :schools, :easting, :text
    add_column :schools, :northing, :text
    add_column :schools, :geolocation, :point
  end
end
