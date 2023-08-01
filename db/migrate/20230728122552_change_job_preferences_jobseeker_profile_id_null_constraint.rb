class ChangeJobPreferencesJobseekerProfileIdNullConstraint < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    add_not_null_constraint :job_preferences, :jobseeker_profile_id, name: "job_preferences_jobseeker_profile_id_null", validate: false
    validate_not_null_constraint :job_preferences, :jobseeker_profile_id, name: "job_preferences_jobseeker_profile_id_null"

    change_column_null :job_preferences, :jobseeker_profile_id, false
    remove_check_constraint :job_preferences, name: "job_preferences_jobseeker_profile_id_null"
  end

  def down
    change_column_null :job_preferences, :jobseeker_profile_id, true
  end
end
