class AddJobseekerProfileIdToTrainingAndCpd < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_column :training_and_cpds, :jobseeker_profile_id, :uuid
    add_index :training_and_cpds, :jobseeker_profile_id, algorithm: :concurrently
    add_foreign_key :training_and_cpds, :jobseeker_profiles, validate: false
    validate_foreign_key :training_and_cpds, :jobseeker_profiles
  end
end
