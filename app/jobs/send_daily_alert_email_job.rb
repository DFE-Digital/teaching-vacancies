class SendDailyAlertEmailJob < AlertEmail::Base
  queue_as :default

  def subscriptions
    Subscription.active.daily
  end

  def from_date
    2.days.ago.to_date
  end
end
