class AddPhaseToVacancy < ActiveRecord::Migration[6.1]
  def change
    add_column :vacancies, :phase, :integer
  end
end
