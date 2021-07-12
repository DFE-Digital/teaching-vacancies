class AddSearchVectorColumnToVacancies < ActiveRecord::Migration[6.1]
  def change
    add_column :vacancies, :search_vector, :tsvector
    add_index :vacancies, :search_vector, using: "gin"
  end
end
