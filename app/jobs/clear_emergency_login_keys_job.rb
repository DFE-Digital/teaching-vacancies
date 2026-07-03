class ClearEmergencyLoginKeysJob < SolidQueueJob
  queue_as :low

  def perform
    EmergencyLoginKey.delete_all
  end
end
