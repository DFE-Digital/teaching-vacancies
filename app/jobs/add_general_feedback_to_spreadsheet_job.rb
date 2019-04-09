require 'add_general_feedback_to_spreadsheet'

class AddGeneralFeedbackToSpreadsheetJob < ApplicationJob
  queue_as :audit_general_feedback

  def perform
    AddGeneralFeedbackToSpreadsheet.new.run!
  end
end
