class AddExternalReferenceToAddFailedImportedVacancyTable < ActiveRecord::Migration[7.0]
  def change
    add_column :failed_imported_vacancies, :external_reference, :string
  end
end
