class RemovePublisherIdFromEmergencyLoginKeys < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :emergency_login_keys, :publisher_id, :uuid }
  end
end
