class CreateJobseekerProfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :jobseeker_profiles, id: :uuid do |t|

      t.timestamps
    end
  end
end
