class AddImportedFieldsToVacancy < ActiveRecord::Migration[6.1]
  def change
    add_column :vacancies, :external_feed_source, :string
    add_column :vacancies, :external_reference, :string
    add_column :vacancies, :external_advert_url, :string
    add_column :vacancies, :external_documents, :jsonb, default: []
  end
end
