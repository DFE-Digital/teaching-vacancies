class ChangeOrganisationVacanciesOrganisationIdNullConstraint < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    add_not_null_constraint :organisation_vacancies, :organisation_id, name: "organisation_vacancies_organisation_id_null", validate: false
    validate_not_null_constraint :organisation_vacancies, :organisation_id, name: "organisation_vacancies_organisation_id_null"

    change_column_null :organisation_vacancies, :organisation_id, false
    remove_check_constraint :organisation_vacancies, name: "organisation_vacancies_organisation_id_null"
  end

  def down
    change_column_null :organisation_vacancies, :organisation_id, true
  end
end