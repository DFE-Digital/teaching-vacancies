class SendDailyAlertEmailJob < AlertEmail::Base
  queue_as :queue_daily_alerts

  def subscriptions
    Subscription.daily
  end

  def from_date
    Time.zone.yesterday
  end
end
