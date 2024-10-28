class AddOwnerToEmergencyLoginKeys < ActiveRecord::Migration[7.1]
  def up
    # Make publisher_id nullable to avoid NOT NULL constraint issues during data migration
    change_column_null :emergency_login_keys, :publisher_id, true
    # Add polymorphic owner reference
    add_reference :emergency_login_keys, :owner, polymorphic: true, type: :uuid, null: true

    # Migrate existing records.
    EmergencyLoginKey.reset_column_information
    EmergencyLoginKey.find_each do |key|
      key.update!(owner_id: key.publisher_id, owner_type: 'Publisher') if key.publisher_id.present?
    end
  end

  def down
    # Migrate data back from owner columns
    EmergencyLoginKey.where(owner_type: 'Publisher').find_each do |key|
      key.update!(publisher_id: key.owner_id)
    end

    # Remove owner reference columns only if they exist
    remove_column :emergency_login_keys, :owner_id if column_exists?(:emergency_login_keys, :owner_id)
    remove_column :emergency_login_keys, :owner_type if column_exists?(:emergency_login_keys, :owner_type)
  end
end
