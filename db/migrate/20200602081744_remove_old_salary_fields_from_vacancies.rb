class RemoveOldSalaryFieldsFromVacancies < ActiveRecord::Migration[5.2]
  def change
    remove_column :vacancies, :min_pay_scale_id
    remove_column :vacancies, :max_pay_scale_id
    remove_column :vacancies, :minimum_salary
    remove_column :vacancies, :maximum_salary
  end
end
