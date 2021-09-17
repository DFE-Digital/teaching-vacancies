class AddGeopointToOrganisation < ActiveRecord::Migration[6.1]
  def change
    add_column :organisations, :geopoint, :st_point, geographic: true
    add_index :organisations, :geopoint, using: :gist
  end
end
