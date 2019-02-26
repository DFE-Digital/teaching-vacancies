class SendDailyAlertEmailJob < ApplicationJob
  queue_as :daily_alert_email

  def perform
    Subscription.ongoing.each do |s|
      next if s.alert_run_today?

      vacancies = vacancies_for_subscription(s)
      next if vacancies.blank?

      Rails.logger.info("Sidekiq: Sending vacancy alerts for #{vacancies.count} vacancies")

      AlertMailer.daily_alert(s.id, vacancies.pluck(:id)).deliver_later
    end
  end

  def vacancies_for_subscription(subscription)
    subscription.vacancies_for_range(Time.zone.yesterday, Time.zone.today).limit(500)
  end
end