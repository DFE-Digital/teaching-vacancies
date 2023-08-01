class ChangeJobApplicationsVacancyIdNullConstraint < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    add_not_null_constraint :job_applications, :vacancy_id, name: "job_applications_vacancy_id_null", validate: false
    validate_not_null_constraint :job_applications, :vacancy_id, name: "job_applications_vacancy_id_null"

    change_column_null :job_applications, :vacancy_id, false
    remove_check_constraint :job_applications, name: "job_applications_vacancy_id_null"
  end

  def down
    change_column_null :job_applications, :vacancy_id, true
  end
end
