class RemoveOldSalaryFieldIndexesFromVacancies < ActiveRecord::Migration[5.2]
  def change
    remove_index :vacancies, name: "index_vacancies_on_max_pay_scale_id"
    remove_index :vacancies, name: "index_vacancies_on_min_pay_scale_id"
  end
end
