class AddHourlyRateToVacancies < ActiveRecord::Migration[7.1]
  def change
    add_column :vacancies, :hourly_rate, :string
  end
end
