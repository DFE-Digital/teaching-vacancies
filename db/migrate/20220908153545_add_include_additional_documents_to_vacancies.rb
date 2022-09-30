class AddIncludeAdditionalDocumentsToVacancies < ActiveRecord::Migration[7.0]
  def change
    add_column :vacancies, :include_additional_documents, :boolean
  end
end
