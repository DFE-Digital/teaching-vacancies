class RenameSchoolVisitsToSchoolVisitsDetails < ActiveRecord::Migration[7.0]
  def change
    rename_column :vacancies, :school_visits, :school_visits_details
  end
end
