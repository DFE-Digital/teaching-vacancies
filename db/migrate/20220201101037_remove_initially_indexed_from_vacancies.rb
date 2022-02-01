class RemoveInitiallyIndexedFromVacancies < ActiveRecord::Migration[6.1]
  def change
    remove_index :vacancies, :initially_indexed
    remove_column :vacancies, :initially_indexed, :boolean
  end
end
