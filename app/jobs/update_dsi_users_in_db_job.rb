require "update_dsi_users_in_db"

class UpdateDsiUsersInDbJob < ActiveJob::Base
  queue_as :low

  def perform
    UpdateDsiUsersInDb.new.run!
  end
end
