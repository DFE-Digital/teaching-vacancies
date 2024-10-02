class AddFlexiWorkingToVacancy < ActiveRecord::Migration[7.1]
  def change
    add_column :vacancies, :flexi_working, :string
  end
end
