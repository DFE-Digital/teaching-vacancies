class AddIndexToVacanciesType < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :vacancies, :type, algorithm: :concurrently
  end
end
