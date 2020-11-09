class SendWeeklyAlertEmailJob < AlertEmail::Base
  queue_as :queue_weekly_alerts

  def subscriptions
    Subscription.active.weekly
  end

  def from_date
    1.week.ago.to_date
  end
end
