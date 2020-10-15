class AddGroupTypeToOrganisations < ActiveRecord::Migration[6.0]
  def change
    add_column :organisations, :group_type, :string
  end
end
