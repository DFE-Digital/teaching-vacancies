class UpdateWeeklyHoursVacancyColumn < ActiveRecord::Migration[5.1]
  def change
    change_column :vacancies, :weekly_hours, :string
  end
end
