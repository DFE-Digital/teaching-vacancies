class RemoveVacancyStatus < ActiveRecord::Migration[7.2]
  def change
    safety_assured { remove_column :vacancies, :status, :integer }
  end
end
