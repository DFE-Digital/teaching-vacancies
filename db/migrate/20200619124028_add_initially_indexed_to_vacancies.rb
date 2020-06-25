class AddInitiallyIndexedToVacancies < ActiveRecord::Migration[5.2]
  def change
    add_column :vacancies, :initially_indexed, :boolean, default: false
    add_index :vacancies, :initially_indexed
  end
end
