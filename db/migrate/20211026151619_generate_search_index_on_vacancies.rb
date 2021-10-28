class GenerateSearchIndexOnVacancies < ActiveRecord::Migration[6.1]
  def change
    add_column :vacancies, :searchable_content, :tsvector
    add_index :vacancies, :searchable_content, using: :gin
  end
end
