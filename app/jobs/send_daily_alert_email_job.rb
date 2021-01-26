class SendDailyAlertEmailJob < AlertEmail::Base
  queue_as :default

  def subscriptions
    Subscription.active.daily
  end

  def from_date
    Time.zone.yesterday
  end
end
