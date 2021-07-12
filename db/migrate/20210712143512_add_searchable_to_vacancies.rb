class AddSearchableToVacancies < ActiveRecord::Migration[6.1]
  def change
    add_column :vacancies, :searchable, :tsvector
    add_index :vacancies, :searchable, using: :gin
  end
end
