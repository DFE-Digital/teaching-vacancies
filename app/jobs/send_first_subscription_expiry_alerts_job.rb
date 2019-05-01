class SendFirstSubscriptionExpiryAlertsJob < ApplicationJob
  queue_as :send_expiry_alerts

  def perform
    Subscription.expiring_in_7_days.each do |s|
      SubscriptionMailer.first_expiry_warning(s.id).deliver_later
    end
  end
end