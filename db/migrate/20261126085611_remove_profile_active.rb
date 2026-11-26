class RemoveProfileActive < ActiveRecord::Migration[8.1]
  def change
    safety_assured do
      remove_column :jobseeker_profiles, :active, :boolean
      remove_column :jobseeker_profiles, :requested_hidden_profile, :boolean
      drop_table :jobseeker_profile_excluded_organisations, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
        t.datetime "created_at", null: false
        t.uuid "jobseeker_profile_id", null: false
        t.uuid "organisation_id", null: false
        t.datetime "updated_at", null: false
      end
    end
  end
end
