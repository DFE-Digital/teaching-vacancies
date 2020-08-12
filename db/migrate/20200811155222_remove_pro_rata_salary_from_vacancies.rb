class RemoveProRataSalaryFromVacancies < ActiveRecord::Migration[5.2]
  def change
    remove_column :vacancies, :pro_rata_salary, :boolean
  end
end
