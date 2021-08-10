class DropVacancyCompletedStep < ActiveRecord::Migration[6.1]
  def change
    remove_column :vacancies, :completed_step, :integer
  end
end
