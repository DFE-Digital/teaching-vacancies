class AddLocalAuthorityFieldsToOrganisations < ActiveRecord::Migration[6.0]
  def change
    add_column :organisations, :local_authority_code, :string
    remove_column :organisations, :local_authority
  end
end
