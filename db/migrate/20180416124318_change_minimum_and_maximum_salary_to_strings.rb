class ChangeMinimumAndMaximumSalaryToStrings < ActiveRecord::Migration[5.1]
  def change
    change_column :vacancies, :minimum_salary, :string
    change_column :vacancies, :maximum_salary, :string
  end
end
