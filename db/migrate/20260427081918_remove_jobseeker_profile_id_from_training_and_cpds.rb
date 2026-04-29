class RemoveJobseekerProfileIdFromTrainingAndCpds < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    remove_foreign_key :training_and_cpds, :jobseeker_profiles, if_exists: true
    remove_index :training_and_cpds, column: :jobseeker_profile_id, algorithm: :concurrently, if_exists: true
    add_not_null_constraint :training_and_cpds, :job_application_id, name: "training_and_cpds_job_application_id_null", validate: false
    validate_not_null_constraint :training_and_cpds, :job_application_id, name: "training_and_cpds_job_application_id_null"
    change_column_null :training_and_cpds, :job_application_id, false
    remove_check_constraint :training_and_cpds, name: "training_and_cpds_job_application_id_null"
  end
end
