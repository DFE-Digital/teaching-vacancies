class AddSavedJobsVacancyIdIndex < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :saved_jobs, ["vacancy_id"], name: :index_saved_jobs_vacancy_id, algorithm: :concurrently
  end
end
