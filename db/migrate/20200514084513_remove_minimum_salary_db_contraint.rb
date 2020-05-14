class RemoveMinimumSalaryDbContraint < ActiveRecord::Migration[5.2]
  def change
    change_column :vacancies, :minimum_salary, :string, null: true
  end
end
