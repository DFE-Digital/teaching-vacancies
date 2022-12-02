class AddFailedImportedVacancyTable < ActiveRecord::Migration[7.0]
  def change
    create_table :failed_imported_vacancies, id: :uuid do |t|
      t.string :import_errors, array: true, default: []
      t.string :source, null: false
      t.timestamps
    end
  end
end
