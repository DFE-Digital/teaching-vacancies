class SendFinalSubscriptionExpiryAlertsJob < ApplicationJob
  queue_as :send_expiry_alerts

  def perform
    Subscription.due_final_expiry_notice.each do |s|
      SubscriptionMailer.final_expiry_warning(s.id).deliver_later
    end
  end
end