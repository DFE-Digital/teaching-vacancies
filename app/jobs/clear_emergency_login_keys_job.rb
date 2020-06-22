class ClearEmergencyLoginKeysJob < ApplicationJob
  queue_as :clear_emergency_login_keys

  def perform
    EmergencyLoginKey.delete_all
  end
end
