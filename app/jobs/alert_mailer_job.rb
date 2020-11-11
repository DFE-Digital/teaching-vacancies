class AlertMailerJob < ActionMailer::MailDeliveryJob
  EXPIRES_IN = 4.hours

  before_enqueue do
    subscription.create_alert_run
  end

  after_enqueue do
    alert_run.update(job_id: provider_job_id)
  end

  around_perform do |_job, block|
    block.call unless job_expired? || job_already_run?
  end

  after_perform do
    alert_run.update(status: :sent)
  end

private

  def job_already_run?
    alert_run.sent?
  end

  def job_expired?
    (alert_run.created_at + EXPIRES_IN) < Time.zone.now
  end

  def subscription
    @subscription ||= Subscription.find(subscription_id)
  end

  def subscription_id
    arguments.last[:args].first
  end

  def alert_run
    @alert_run ||= subscription.alert_run_today
  end
end
