class AddOrganisationsIdOrganisationPublisherPreferencesOrganisationIdFk < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_foreign_key :organisation_publisher_preferences, :organisations, column: :organisation_id, primary_key: :id, validate: false
    validate_foreign_key :organisation_publisher_preferences, :organisations
  end
end
