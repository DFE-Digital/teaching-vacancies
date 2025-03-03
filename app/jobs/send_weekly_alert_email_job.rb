class SendWeeklyAlertEmailJob < AlertEmail::Base
  queue_as :default

  def subscriptions
    Subscription.active.weekly
  end

  # :nocov:
  def from_date
    7.days.ago.to_date
  end
  # :nocov:
end
