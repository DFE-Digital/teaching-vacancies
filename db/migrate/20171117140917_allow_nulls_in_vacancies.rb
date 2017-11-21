class AllowNullsInVacancies < ActiveRecord::Migration[5.1]
  def change
    change_column_null :vacancies, :essential_requirements, true
  end
end
