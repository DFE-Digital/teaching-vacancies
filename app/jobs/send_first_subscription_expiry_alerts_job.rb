class SendFirstSubscriptionExpiryAlertsJob < ApplicationJob
  queue_as :send_expiry_alerts

  def perform
    Subscription.due_first_expiry_notice.each do |s|
      SubscriptionMailer.first_expiry_warning(s.id).deliver_later
    end
  end
end