class UpdateDSIUsersInDbJob < ApplicationJob
  queue_as :low

  def perform
    Publishers::DfeSignIn::UpdateUsersInDb.new.call
  end
end
