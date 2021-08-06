class AddCompletedStepsToVacancy < ActiveRecord::Migration[6.1]
  def change
    add_column :vacancies, :completed_steps, :string, array: true, default: [], null: false
  end
end
