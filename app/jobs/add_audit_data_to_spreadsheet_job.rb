require 'add_audit_data_to_spreadsheet'

class AddAuditDataToSpreadsheetJob < ApplicationJob
  queue_as :audit_spreadsheet

  def perform(category)
    AddAuditDataToSpreadsheet.new(category).run!
  end
end