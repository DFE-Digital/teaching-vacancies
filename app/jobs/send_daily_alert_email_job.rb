class SendDailyAlertEmailJob < ApplicationJob
  def perform
    Subscription.ongoing.each do |s|
      vacancies = vacancies_for_subscription(s)
      next if vacancies.blank?

      Rails.logger.info("Sidekiq: Sending vacancy alerts for #{vacancies.count} vacancies")

      job = AlertMailer.daily_alert(s.id, vacancies.pluck(:id)).deliver_later

      s.log_alert_run(job.provider_job_id)
    end
  end

  def vacancies_for_subscription(subscription)
    subscription.vacancies_for_range(Time.zone.yesterday, Time.zone.today).limit(500)
  end
end