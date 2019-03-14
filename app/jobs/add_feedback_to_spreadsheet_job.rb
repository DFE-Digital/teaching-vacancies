require 'add_feedback_to_spreadsheet'

class AddFeedbackToSpreadsheetJob < ApplicationJob
  queue_as :audit_feedback

  def perform
    AddFeedbackToSpreadsheet.new.run!
  end
end
