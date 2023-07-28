class ChangeOrganisationPublisherPreferencesPublisherPreferenceIdNullConstraint < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    add_not_null_constraint :organisation_publisher_preferences, :publisher_preference_id, name: "organisation_publisher_preferences_publisher_preference_id_null", validate: false
    validate_not_null_constraint :organisation_publisher_preferences, :publisher_preference_id, name: "organisation_publisher_preferences_publisher_preference_id_null"

    change_column_null :organisation_publisher_preferences, :publisher_preference_id, false
    remove_check_constraint :organisation_publisher_preferences, name: "organisation_publisher_preferences_publisher_preference_id_null"
  end

  def down
    change_column_null :organisation_publisher_preferences, :publisher_preference_id, true
  end
end
