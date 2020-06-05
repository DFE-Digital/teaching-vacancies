class AddSchoolVisitsToVacancies < ActiveRecord::Migration[5.2]
  def change
    add_column :vacancies, :school_visits, :text
  end
end
