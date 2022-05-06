class AddIndicesWhereMissing < ActiveRecord::Migration[6.1]
  def change
    add_index :organisation_vacancies, %i[organisation_id vacancy_id], unique: true
    add_index :organisation_vacancies, %i[vacancy_id organisation_id], unique: true
  end
end
