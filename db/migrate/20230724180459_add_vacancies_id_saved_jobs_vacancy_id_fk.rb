class AddVacanciesIdSavedJobsVacancyIdFk < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_foreign_key :saved_jobs, :vacancies, column: :vacancy_id, primary_key: :id, validate: false
    validate_foreign_key :saved_jobs, :vacancies
  end
end
