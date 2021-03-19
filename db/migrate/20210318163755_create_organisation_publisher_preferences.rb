class CreateOrganisationPublisherPreferences < ActiveRecord::Migration[6.1]
  def change
    create_table :organisation_publisher_preferences, id: :uuid do |t|
      t.uuid :organisation_id
      t.uuid :publisher_preference_id

      t.timestamps
    end

    remove_column :publisher_preferences, :managed_organisations, :string
    remove_column :publisher_preferences, :managed_school_ids, :string

    rename_column :publisher_preferences, :school_group_id, :organisation_id
  end
end
