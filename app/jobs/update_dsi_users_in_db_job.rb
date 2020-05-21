require 'update_dsi_users_in_db'

class UpdateDfeSignInUsersJob < ApplicationJob
  queue_as :update_dsi_users_in_db

  def perform
    UpdateDfeSignInUsers.new.run
  end
end
