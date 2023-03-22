class AddHiddenOrganisationFieldsToJobseekerProfile < ActiveRecord::Migration[7.0]
  def change
    create_table :jobseeker_profile_excluded_organisations, id: :uuid do |t|
      t.references :jobseeker_profile, null: false, foreign_key: true, type: :uuid, index: { name: "index_excluded_organisations_on_jobseeker_profile_id" }
      t.references :organisation, null: false, foreign_key: true, type: :uuid, index: { name: "index_excluded_organisations_on_organisation_id" }
      t.timestamps
    end

    add_column :jobseeker_profiles, :hide_profile, :boolean
  end
end
