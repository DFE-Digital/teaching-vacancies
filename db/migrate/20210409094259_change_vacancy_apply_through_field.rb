class ChangeVacancyApplyThroughField < ActiveRecord::Migration[6.1]
  # Minimal version of Vacancy model class to avoid old data migration update calls to fail due to missing field/methods
  # on the current real model class.
  class Vacancy < ActiveRecord::Base; end

  def up
    add_column :vacancies, :enable_job_applications, :boolean, null: true
    Vacancy.where("apply_through_teaching_vacancies = 'yes'").update_all("enable_job_applications = TRUE")
    Vacancy.where("apply_through_teaching_vacancies = 'no'").update_all("enable_job_applications = FALSE")
    remove_column :vacancies, :apply_through_teaching_vacancies
  end

  def down
    add_column :vacancies, :apply_through_teaching_vacancies, :string
    Vacancy.where("enable_job_applications = TRUE").update_all("apply_through_teaching_vacancies = 'yes'")
    Vacancy.where("enable_job_applications = FALSE").update_all("apply_through_teaching_vacancies = 'no'")
    remove_column :vacancies, :enable_job_applications
  end
end
