class AddLocalAuthorityWithinToOrganisations < ActiveRecord::Migration[6.0]
  def change
    add_column :organisations, :local_authority_within, :string
  end
end
