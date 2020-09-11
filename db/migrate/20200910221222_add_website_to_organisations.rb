class AddWebsiteToOrganisations < ActiveRecord::Migration[6.0]
  def change
    add_column :organisations, :website, :string
  end
end
