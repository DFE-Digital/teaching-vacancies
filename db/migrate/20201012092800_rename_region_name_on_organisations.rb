class RenameRegionNameOnOrganisations < ActiveRecord::Migration[6.0]
  def change
    rename_column :organisations, :region_name, :region
  end
end
