class AddSchoolVisitsBoolToVacancies < ActiveRecord::Migration[7.0]
  def change
    add_column :vacancies, :school_visits, :boolean
  end
end
