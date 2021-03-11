class AlertEmail::Base < ApplicationJob
  def perform
    return if DisableExpensiveJobs.enabled?

    subscriptions.each do |subscription|
      next if subscription.alert_run_today?

      vacancies = vacancies_for_subscription(subscription)
      next if vacancies.blank?

      Jobseekers::AlertMailer.alert(subscription.id, vacancies.pluck(:id)).deliver_later
    end
  end

  def vacancies_for_subscription(subscription)
    subscription.vacancies_for_range(from_date, Date.current)
  end
end
