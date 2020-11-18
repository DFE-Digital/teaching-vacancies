class RemoveVacanciesConstraints < ActiveRecord::Migration[6.0]
  def change
    change_column_null :vacancies, :job_title, true
  end
end
