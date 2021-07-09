class AddSearchVectorColumnToVacancies < ActiveRecord::Migration[6.1]
  def change
    add_column :vacancies, :searchable, :tsvector
  end
end
