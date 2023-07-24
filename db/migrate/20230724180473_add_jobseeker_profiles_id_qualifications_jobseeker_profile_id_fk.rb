class AddJobseekerProfilesIdQualificationsJobseekerProfileIdFk < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_foreign_key :qualifications, :jobseeker_profiles, column: :jobseeker_profile_id, primary_key: :id, validate: false
    validate_foreign_key :qualifications, :jobseeker_profiles
  end
end
