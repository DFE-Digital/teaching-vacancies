class ChangeEmergencyLoginKeysPublisherIdNullConstraint < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    add_not_null_constraint :emergency_login_keys, :publisher_id, name: "emergency_login_keys_publisher_id_null", validate: false
    validate_not_null_constraint :emergency_login_keys, :publisher_id, name: "emergency_login_keys_publisher_id_null"

    change_column_null :emergency_login_keys, :publisher_id, false
    remove_check_constraint :emergency_login_keys, name: "emergency_login_keys_publisher_id_null"
  end

  def down
    change_column_null :emergency_login_keys, :publisher_id, true
  end
end
