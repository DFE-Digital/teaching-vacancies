class AddVacanciesIdFeedbacksVacancyIdFk < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_foreign_key :feedbacks, :vacancies, column: :vacancy_id, primary_key: :id, validate: false
    validate_foreign_key :feedbacks, :vacancies
  end
end
