class AddCompletedStepToVacancies < ActiveRecord::Migration[5.2]
  def change
    add_column :vacancies, :completed_step, :integer
  end
end
