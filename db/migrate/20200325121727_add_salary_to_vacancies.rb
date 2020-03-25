class AddSalaryToVacancies < ActiveRecord::Migration[5.2]
  def change
    add_column :vacancies, :salary, :string unless column_exists? :vacancies, :salary
  end
end
