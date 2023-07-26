class AddOrganisationsIdOrganisationVacanciesOrganisationIdFk < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_foreign_key :organisation_vacancies, :organisations, column: :organisation_id, primary_key: :id, validate: false
    validate_foreign_key :organisation_vacancies, :organisations
  end
end
