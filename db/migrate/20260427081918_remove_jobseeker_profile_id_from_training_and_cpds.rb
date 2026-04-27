class RemoveJobseekerProfileIdFromTrainingAndCpds < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    remove_foreign_key :training_and_cpds, :jobseeker_profiles
    remove_index :training_and_cpds, column: :jobseeker_profile_id, algorithm: :concurrently
    change_column_null :training_and_cpds, :job_application_id, false
  end
end
