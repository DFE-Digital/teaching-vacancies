require 'add_dsi_users_to_spreadsheet'

class AddDSIUsersToSpreadsheetJob < ApplicationJob
  queue_as :dsi_user_data

  def perform
    AddDSIUsersToSpreadsheet.new.all_service_users
  end
end