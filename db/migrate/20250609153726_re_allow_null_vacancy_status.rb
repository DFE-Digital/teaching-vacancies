class ReAllowNullVacancyStatus < ActiveRecord::Migration[7.2]
  def change
    # need to re-allow null in status column as it is now ignored
    change_column_null :vacancies, :status, true
  end
end
