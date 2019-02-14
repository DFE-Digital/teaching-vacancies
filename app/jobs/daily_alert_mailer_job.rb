class DailyAlertMailerJob < ActionMailer::DeliveryJob
  EXPIRES_IN = 4.hours

  before_enqueue do
    subscription.create_alert_run
  end

  after_enqueue do
    alert_run.update(job_id: provider_job_id)
  end

  around_perform do |_job, block|
    alert_run = subscription.alert_run_today
    block.call unless job_expired?(alert_run)
  end

  private

  def job_expired?(alert_run)
    (alert_run.created_at + EXPIRES_IN) < Time.zone.now
  end

  def subscription
    @subscription ||= Subscription.find(subscription_id)
  end

  def subscription_id
    arguments[3]
  end
end