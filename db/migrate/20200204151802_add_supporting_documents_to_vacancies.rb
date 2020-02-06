class AddSupportingDocumentsToVacancies < ActiveRecord::Migration[5.2]
  def change
    add_column :vacancies, :supporting_documents, :string
  end
end
