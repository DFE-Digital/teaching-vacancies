class AddIndexToVacanciesContactEmail < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :vacancies, :contact_email, algorithm: :concurrently
  end
end
