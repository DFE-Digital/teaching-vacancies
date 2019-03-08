require 'add_audit_data'

class AddAuditDataToSpreadsheetJob < ApplicationJob
  queue_as :audit_spreadsheet

  def perform(category)
    AddAuditData.new(category).run!
  end
end