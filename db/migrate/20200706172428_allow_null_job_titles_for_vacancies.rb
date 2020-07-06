class AllowNullJobTitlesForVacancies < ActiveRecord::Migration[5.2]
  def change
    change_column_null :vacancies, :job_title, true
  end
end
