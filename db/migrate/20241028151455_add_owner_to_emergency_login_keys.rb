class AddOwnerToEmergencyLoginKeys < ActiveRecord::Migration[7.1]
  def up
    # Emergency login keys are useless after 10 mins so no need to backfill them
    EmergencyLoginKey.destroy_all

    # Make publisher_id nullable to avoid NOT NULL constraint issues before deleting this column
    change_column_null :emergency_login_keys, :publisher_id, true
    # Add polymorphic owner reference
    add_reference :emergency_login_keys, :owner, polymorphic: true, type: :uuid, null: false
  end

  def down
    # Emergency login keys are useless after 10 mins so no need to backfill them
    EmergencyLoginKey.destroy_all

    # Remove owner reference columns only if they exist
    remove_column :emergency_login_keys, :owner_id
    remove_column :emergency_login_keys, :owner_type

    change_column_null :emergency_login_keys, :publisher_id, false
  end
end
