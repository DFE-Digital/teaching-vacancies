class RemoveWeeklyHoursFromVacancies < ActiveRecord::Migration[5.2]
  def change
    remove_column :vacancies, :weekly_hours, :string
  end
end
