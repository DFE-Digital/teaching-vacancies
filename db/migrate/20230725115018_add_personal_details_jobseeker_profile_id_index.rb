class AddPersonalDetailsJobseekerProfileIdIndex < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :personal_details, ["jobseeker_profile_id"], name: :index_personal_details_jobseeker_profile_id, unique: true, algorithm: :concurrently
    remove_index :personal_details, name: :index_personal_details_on_jobseeker_profile_id, algorithm: :concurrently
  end
end
