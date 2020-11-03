namespace :daily_emails do
  task send: :environment do
    SendDailyAlertEmailJob.perform_later
  end
end
