class SendFinalSubscriptionExpiryAlertsJob < ApplicationJob
  queue_as :send_expiry_alerts

  def perform
    Subscription.expiring_tomorrow.each do |s|
      SubscriptionMailer.final_expiry_warning(s.id).deliver_later
    end
  end
end