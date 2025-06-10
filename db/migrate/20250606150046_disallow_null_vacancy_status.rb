class DisallowNullVacancyStatus < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_not_null_constraint :vacancies, :status, name: "vacancies_status_null", validate: false
    # You can use `validate_constraint_in_background` if you have a very large table
    # and want to validate the constraint using background schema migrations.
    validate_not_null_constraint :vacancies, :status, name: "vacancies_status_null"

    change_column_null :vacancies, :status, false
    remove_check_constraint :vacancies, name: "vacancies_status_null"
  end
end
