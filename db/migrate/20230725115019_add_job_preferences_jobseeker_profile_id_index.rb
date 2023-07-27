class AddJobPreferencesJobseekerProfileIdIndex < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :job_preferences, ["jobseeker_profile_id"], name: :index_job_preferences_jobseeker_profile_id, unique: true, algorithm: :concurrently
    remove_index :job_preferences, name: :index_job_preferences_on_jobseeker_profile_id, algorithm: :concurrently
  end
end
