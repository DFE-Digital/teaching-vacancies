class AddAboutYouToJobseekerProfiles < ActiveRecord::Migration[7.0]
  def change
    add_column :jobseeker_profiles, :about_you, :string
  end
end
