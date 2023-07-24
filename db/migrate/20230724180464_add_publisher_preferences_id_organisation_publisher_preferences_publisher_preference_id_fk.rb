class AddPublisherPreferencesIdOrganisationPublisherPreferencesPublisherPreferenceIdFk < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_foreign_key :organisation_publisher_preferences, :publisher_preferences, column: :publisher_preference_id, primary_key: :id, validate: false
    validate_foreign_key :organisation_publisher_preferences, :publisher_preferences
  end
end
