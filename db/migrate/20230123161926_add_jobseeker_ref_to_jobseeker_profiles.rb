class AddJobseekerRefToJobseekerProfiles < ActiveRecord::Migration[7.0]
  def change
    add_reference :jobseeker_profiles, :jobseeker, foreign_key: true, type: :uuid
  end
end
