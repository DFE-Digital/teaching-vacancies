class AddProRataSalaryToVacancies < ActiveRecord::Migration[5.2]
  def change
    add_column :vacancies, :pro_rata_salary, :boolean

    remove_column :vacancies, :full_time_equivalent, :float
  end
end
