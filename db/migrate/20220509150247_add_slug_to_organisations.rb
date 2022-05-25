class AddSlugToOrganisations < ActiveRecord::Migration[6.1]
  def change
    add_column :organisations, :slug, :string
    add_index :organisations, :slug, unique: true
  end
end
