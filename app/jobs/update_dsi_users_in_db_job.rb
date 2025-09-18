# This is loaded correctly by Zeitwerk due to a custom inflection in config/inflections.rb
class UpdateDSIUsersInDbJob < ApplicationJob
  queue_as :low

  def perform
    Publishers::DfeSignIn::UpdateUsersInDb.new.call
  end
end
