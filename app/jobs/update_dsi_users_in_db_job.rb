require "update_dsi_users_in_db"

class UpdateDSIUsersInDbJob < ApplicationJob
  queue_as :low

  def perform
    UpdateDSIUsersInDb.new.run!
  end
end
