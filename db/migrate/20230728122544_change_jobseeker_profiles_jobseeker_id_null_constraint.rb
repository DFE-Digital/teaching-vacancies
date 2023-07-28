class ChangeJobseekerProfilesJobseekerIdNullConstraint < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    add_not_null_constraint :jobseeker_profiles, :jobseeker_id, name: "jobseeker_profiles_jobseeker_id_null", validate: false
    validate_not_null_constraint :jobseeker_profiles, :jobseeker_id, name: "jobseeker_profiles_jobseeker_id_null"

    change_column_null :jobseeker_profiles, :jobseeker_id, false
    remove_check_constraint :jobseeker_profiles, name: "jobseeker_profiles_jobseeker_id_null"
  end

  def down
    change_column_null :jobseeker_profiles, :jobseeker_id, true
  end
end
