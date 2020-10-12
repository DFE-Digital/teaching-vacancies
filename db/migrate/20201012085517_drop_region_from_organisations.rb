class DropRegionFromOrganisations < ActiveRecord::Migration[6.0]
  def change
    remove_index :organisations, name: "index_organisations_on_region_id"
    remove_column :organisations, :region_id
    drop_table :regions
  end
end
