class CreateJobseekerProfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :jobseeker_profiles, id: :uuid do |t|
      t.string :location
      t.integer :radius
      t.geography "location_preference", limit: {:srid=>4326, :type=>"geometry", :geographic=>true}

      t.timestamps
    end
  end
end
