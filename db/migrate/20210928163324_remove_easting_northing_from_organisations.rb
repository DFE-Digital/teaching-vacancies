class RemoveEastingNorthingFromOrganisations < ActiveRecord::Migration[6.1]
  def change
    remove_column :organisations, :easting
    remove_column :organisations, :northing
  end
end
