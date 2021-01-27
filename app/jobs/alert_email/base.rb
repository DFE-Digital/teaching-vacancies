class AlertEmail::Base < ApplicationJob
  def perform
    return unless Rails.env.production?

    subscriptions.each do |subscription|
      next if subscription.alert_run_today?

      vacancies = vacancies_for_subscription(subscription)
      next if vacancies.blank?

      AlertMailer.alert(subscription.id, vacancies.pluck(:id)).deliver_later
    end
  end

  def vacancies_for_subscription(subscription)
    subscription.vacancies_for_range(from_date, Date.current).limit(Search::AlertBuilder::MAXIMUM_SUBSCRIPTION_RESULTS)
  end
end
