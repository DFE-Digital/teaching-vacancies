namespace :dsi_spreadsheets do
  desc 'Updates Google spreadsheets with DSI users data'
  task update: :environment do
    AddDSIUsersToSpreadsheetJob.perform_later
    AddDSIApproversToSpreadsheetJob.perform_later
  end
end
