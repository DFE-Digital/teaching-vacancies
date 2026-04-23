class RemoveJobseekerProfileIdFromTrainingAndCpds < ActiveRecord::Migration[7.2]
  def change
    remove_foreign_key :training_and_cpds, :jobseeker_profiles
    remove_index :training_and_cpds, :jobseeker_profile_id
    remove_column :training_and_cpds, :jobseeker_profile_id, :uuid
  end
end
