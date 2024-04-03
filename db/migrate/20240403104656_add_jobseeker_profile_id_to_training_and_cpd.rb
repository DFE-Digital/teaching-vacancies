class AddJobseekerProfileIdToTrainingAndCpd < ActiveRecord::Migration[7.1]
  def change
    add_column :training_and_cpds, :jobseeker_profile_id, :uuid
  end
end
