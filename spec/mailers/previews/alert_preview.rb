class AlertPreview < SubscriptionPreview
  def daily_alert
    AlertMailer.daily_alert(subscription.id, vacancy_ids)
  end

  private

  def vacancy_ids
    Subscription.count.zero? ? FactoryBot.create_list(:vacancy, 5) : Vacancy.all.sample(5)
  end
end