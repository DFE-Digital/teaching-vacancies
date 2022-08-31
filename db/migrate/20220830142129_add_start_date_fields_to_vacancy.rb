class AddStartDateFieldsToVacancy < ActiveRecord::Migration[7.0]
  def change
    add_column :vacancies, :start_date_type, :integer
    add_column :vacancies, :earliest_start_date, :date
    add_column :vacancies, :latest_start_date, :date
    add_column :vacancies, :other_start_date_details, :text
  end
end
