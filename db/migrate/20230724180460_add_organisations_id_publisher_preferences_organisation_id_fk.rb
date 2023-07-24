class AddOrganisationsIdPublisherPreferencesOrganisationIdFk < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_foreign_key :publisher_preferences, :organisations, column: :organisation_id, primary_key: :id, validate: false
    validate_foreign_key :publisher_preferences, :organisations
  end
end
