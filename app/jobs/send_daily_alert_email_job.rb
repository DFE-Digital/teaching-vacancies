class SendDailyAlertEmailJob < AlertEmail::Base
  queue_as :default

  def subscriptions
    Subscription.kept.daily
  end

  def from_date
    Time.zone.yesterday
  end
end
