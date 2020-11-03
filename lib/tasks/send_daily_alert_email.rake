namespace :daily_emails do
  desc "Send daily alerts"
  task send: :environment do
    SendDailyAlertEmailJob.perform_later
  end
end
