class AddActualSalaryToVacancies < ActiveRecord::Migration[6.1]
  def change
    add_column :vacancies, :actual_salary, :string
  end
end
