class SendWeeklyAlertEmailJob < AlertEmail::Base
  queue_as :default

  def subscriptions
    Subscription.kept.weekly
  end

  def from_date
    1.week.ago.to_date
  end
end
