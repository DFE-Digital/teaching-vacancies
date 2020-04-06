class ChangeJobSummaryToNullableColumn < ActiveRecord::Migration[5.2]
  def change
    change_column_null :vacancies, :job_summary, true
  end
end
