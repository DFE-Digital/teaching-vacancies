class ChangeJobApplicationsJobseekerIdNullConstraint < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    add_not_null_constraint :job_applications, :jobseeker_id, name: "job_applications_jobseeker_id_null", validate: false
    validate_not_null_constraint :job_applications, :jobseeker_id, name: "job_applications_jobseeker_id_null"

    change_column_null :job_applications, :jobseeker_id, false
    remove_check_constraint :job_applications, name: "job_applications_jobseeker_id_null"
  end

  def down
    change_column_null :job_applications, :jobseeker_id, true
  end
end
