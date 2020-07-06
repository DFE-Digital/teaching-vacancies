class AllowNullSchoolForVacancies < ActiveRecord::Migration[5.2]
  def change
    change_column_null :vacancies, :school_id, true
  end
end
