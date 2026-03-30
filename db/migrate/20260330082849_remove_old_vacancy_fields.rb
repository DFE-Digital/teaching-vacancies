class RemoveOldVacancyFields < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      remove_column :vacancies, :parental_leave_cover_contract_duration, :string
      remove_column :vacancies, :google_index_removed, :boolean, default: false
      remove_column :vacancies, :full_time_details, :text
      remove_column :vacancies, :part_time_details, :text
    end
  end
end
