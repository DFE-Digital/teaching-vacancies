class RemoveGeolocationFromOrganisations < ActiveRecord::Migration[6.1]
  def change
    remove_column :organisations, :geolocation
  end
end
