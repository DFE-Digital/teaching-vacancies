class RemoveSupportingDocumentsFromVacancies < ActiveRecord::Migration[6.1]
  def change
    remove_column :vacancies, :supporting_documents, :string
  end
end
