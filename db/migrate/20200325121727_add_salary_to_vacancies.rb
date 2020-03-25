class AddSalaryToVacancies < ActiveRecord::Migration[5.2]
  def change
    add_column :vacancies, :salary, :string
  end
end
