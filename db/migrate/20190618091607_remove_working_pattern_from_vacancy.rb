class RemoveWorkingPatternFromVacancy < ActiveRecord::Migration[5.2]
  def change
    remove_column :vacancies, :working_pattern, :integer
  end
end
