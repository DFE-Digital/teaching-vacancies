class AddActiveToJobseekerProfiles < ActiveRecord::Migration[7.0]
  def change
    add_column :jobseeker_profiles, :active, :boolean, null: false, default: false
  end
end
