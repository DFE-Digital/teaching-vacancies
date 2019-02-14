class DailyAlertMailerJob < ActionMailer::DeliveryJob
  around_perform do |job, block|
    subscription = Subscription.find(job.arguments[3])
    alert_run = subscription.alert_run_today
    block.call unless job_expired?(alert_run)
  end

  private

  def job_expired?(alert_run)
    (alert_run.created_at + 4.hours) < Time.zone.now
  end
end