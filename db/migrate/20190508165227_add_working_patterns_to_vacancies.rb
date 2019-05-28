class AddWorkingPatternsToVacancies < ActiveRecord::Migration[5.2]
  def change
    add_column :vacancies, :working_patterns, :integer, array: true
  end
end