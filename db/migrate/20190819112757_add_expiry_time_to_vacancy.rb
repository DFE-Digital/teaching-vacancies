class AddExpiryTimeToVacancy < ActiveRecord::Migration[5.2]
  def change
    add_column :vacancies, :expiry_time, :time
  end
end
