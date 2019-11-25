namespace :spreadsheets do
  desc 'Updates Google spreadsheets with the latest audit data'
  task update: :environment do
    # Note that the exporting of "interest_expression"s and "search_event"s
    # have been intentionally disabled as they were causing Out Of Memory issues
    # in production.

    AddVacanciesToSpreadsheetJob.perform_later
    AddAuditDataToSpreadsheetJob.perform_later('subscription_creation')
    AddVacancyPublishFeedbackToSpreadsheetJob.perform_later
    AddGeneralFeedbackToSpreadsheetJob.perform_later
  end
end
