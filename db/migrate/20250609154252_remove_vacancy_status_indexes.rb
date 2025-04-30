class RemoveVacancyStatusIndexes < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    remove_index :vacancies, name: :index_vacancies_on_status, algorithm: :concurrently
  end
end
