class AddJobseekerProfilesJobseekerIdIndex < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :jobseeker_profiles, ["jobseeker_id"], name: :index_jobseeker_profiles_jobseeker_id, unique: true, algorithm: :concurrently
    remove_index :jobseeker_profiles, name: :index_jobseeker_profiles_on_jobseeker_id, algorithm: :concurrently
  end
end
