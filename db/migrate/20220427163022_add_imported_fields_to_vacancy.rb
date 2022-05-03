class AddImportedFieldsToVacancy < ActiveRecord::Migration[6.1]
  def change
    add_column :vacancies, :external_source, :string
    add_column :vacancies, :external_reference, :string
    add_column :vacancies, :external_advert_url, :string
  end
end
