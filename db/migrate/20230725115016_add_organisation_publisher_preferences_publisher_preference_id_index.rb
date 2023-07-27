class AddOrganisationPublisherPreferencesPublisherPreferenceIdIndex < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :organisation_publisher_preferences, ["publisher_preference_id"], name: :index_organisation_publisher_preferences_publisher_preference_i, algorithm: :concurrently
  end
end
