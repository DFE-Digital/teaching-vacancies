namespace :subscription do
  namespace :expiry_alerts do
    task send: :environment do
      SendFirstSubscriptionExpiryAlertsJob.perform_later
    end
  end
end