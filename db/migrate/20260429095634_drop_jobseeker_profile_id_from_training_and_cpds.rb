class DropJobseekerProfileIdFromTrainingAndCpds < ActiveRecord::Migration[8.0]
  def change
    safety_assured { remove_column :training_and_cpds, :jobseeker_profile_id, :uuid }
  end
end
