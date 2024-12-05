class AddReligionTypeToVacancy < ActiveRecord::Migration[7.1]
  def change
    add_column :vacancies, :religion_type, :integer
  end
end
