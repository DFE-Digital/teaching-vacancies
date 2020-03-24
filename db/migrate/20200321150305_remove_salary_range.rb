class RemoveSalaryRange < ActiveRecord::Migration[5.2]
  def change
    remove_column :vacancies, :minimum_salary
    remove_column :vacancies, :maximum_salary
  end
end
