class CreateVacancyWorkingPatterns < ActiveRecord::Migration[5.2]
  def change
    create_join_table :vacancies, :working_patterns, column_options: { type: :uuid } do |t|
      t.index [:vacancy_id, :working_pattern_id], unique: true, name: 'vacancy_working_pattern'
      t.index [:working_pattern_id, :working_pattern_id], name: 'working_pattern_vacancy'
    end
  end
end
