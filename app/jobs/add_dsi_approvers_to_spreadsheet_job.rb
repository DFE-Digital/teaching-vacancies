require 'add_dsi_approvers_to_spreadsheet'

class AddDSIApproversToSpreadsheetJob < ApplicationJob
  queue_as :dsi_approver_data

  def perform
    AddDSIApproversToSpreadsheet.new.all_service_approvers
  end
end
