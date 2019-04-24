require 'add_vacancy_publish_feedback_to_spreadsheet'

class AddVacancyPublishFeedbackToSpreadsheetJob < ApplicationJob
  queue_as :audit_vacancy_publish_feedback

  def perform
    AddVacancyPublishFeedbackToSpreadsheet.new.run!
  end
end
