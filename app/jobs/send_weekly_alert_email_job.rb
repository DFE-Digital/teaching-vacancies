class SendWeeklyAlertEmailJob < AlertEmail::Base
  queue_as :default

  def subscriptions
    Subscription.active.weekly
  end

  def from_date
    8.days.ago.to_date
  end
end
