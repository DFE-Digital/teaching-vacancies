class AddOwnerToEmergencyLoginKeys < ActiveRecord::Migration[7.0]
  def up
    # Step 1: Make publisher_id nullable to avoid NOT NULL constraint issues during data migration
    change_column_null :emergency_login_keys, :publisher_id, true
    # Step 2: Add polymorphic owner reference
    add_reference :emergency_login_keys, :owner, polymorphic: true, type: :uuid, null: true

    # Step 3: Migrate existing records
    EmergencyLoginKey.reset_column_information
    EmergencyLoginKey.find_each do |key|
      key.update!(owner_id: key.publisher_id, owner_type: 'Publisher') if key.publisher_id.present?
    end
  end

  def down
    # Re-add publisher_id only if it doesn’t exist
    add_column :emergency_login_keys, :publisher_id, :uuid unless column_exists?(:emergency_login_keys, :publisher_id)
    change_column_null :emergency_login_keys, :publisher_id, false
    EmergencyLoginKey.reset_column_information # Ensure ActiveRecord knows publisher_id is back

    # Migrate data back from owner columns
    EmergencyLoginKey.where(owner_type: 'Publisher').find_each do |key|
      key.update!(publisher_id: key.owner_id)
    end

    # Remove owner reference columns only if they exist
    remove_column :emergency_login_keys, :owner_id if column_exists?(:emergency_login_keys, :owner_id)
    remove_column :emergency_login_keys, :owner_type if column_exists?(:emergency_login_keys, :owner_type)
    EmergencyLoginKey.reset_column_information # Ensure ActiveRecord knows owner columns are gone
  end
end
