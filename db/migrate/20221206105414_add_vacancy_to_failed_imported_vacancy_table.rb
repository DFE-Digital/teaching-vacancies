class AddVacancyToFailedImportedVacancyTable < ActiveRecord::Migration[7.0]
  def change
    add_column :failed_imported_vacancies, :vacancy, :jsonb
  end
end
