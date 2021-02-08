class AddFieldsToVacancies < ActiveRecord::Migration[6.1]
  def change
    add_column :vacancies, :apply_through_teaching_vacancies, :string
    add_column :vacancies, :personal_statement_guidance, :text
  end
end
