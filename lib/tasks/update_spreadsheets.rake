namespace :spreadsheets do
  desc 'Updates Google spreadsheets with the latest audit data'
  task update: :environment do
    AddAuditDataToSpreadsheetJob.perform_later('vacancies')
    AddAuditDataToSpreadsheetJob.perform_later('interest_expression')
    AddFeedbackToSpreadsheetJob.perform_later
  end
end
