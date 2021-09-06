class AddWorkingPatternsDetailsToVacancies < ActiveRecord::Migration[6.1]
  def change
    add_column :vacancies, :working_patterns_details, :text
  end
end
