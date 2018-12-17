require 'subscription_confirmation_email'
class NotifySubscriptionConfirmationEmailJob < ApplicationJob
  queue_as :notify_request

  def perform(subscription_id)
    subscription = Subscription.ongoing.find(subscription_id)
    return if subscription.nil?

    SubscriptionConfirmationEmail.new(subscription).call
    Auditor::Audit.new(subscription, 'subscription.daily_alert.confirmation.sent', nil).log
  end
end
