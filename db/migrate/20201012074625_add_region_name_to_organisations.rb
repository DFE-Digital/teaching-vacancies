class AddRegionNameToOrganisations < ActiveRecord::Migration[6.0]
  def change
    add_column :organisations, :region_name, :string
  end
end
