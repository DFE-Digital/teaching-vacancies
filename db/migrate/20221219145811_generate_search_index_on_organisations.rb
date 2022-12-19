class GenerateSearchIndexOnOrganisations < ActiveRecord::Migration[7.0]
  def change
    add_column :organisations, :searchable_content, :tsvector
    add_index :organisations, :searchable_content, using: :gin
  end
end
