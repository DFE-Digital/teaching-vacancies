class SubscriptionExpiryMailerJob < ActionMailer::DeliveryJob
  around_perform do |_job, block|
    block.call unless job_already_run?
  end

  after_perform do
    first_expiry_warning? ? set_first_expiry_flag : set_final_expiry_flag
  end

  private

  def subscription
    @subscription ||= Subscription.find(subscription_id)
  end

  def subscription_id
    arguments[3]
  end

  def job_already_run?
    first_expiry_warning? ? subscription.first_reminder_sent? : subscription.final_reminder_sent?
  end

  def first_expiry_warning?
    arguments[1] == 'first_expiry_warning'
  end

  def set_first_expiry_flag
    subscription.update(first_reminder_sent: true)
  end

  def set_final_expiry_flag
    subscription.update(first_reminder_sent: true, final_reminder_sent: true)
  end
end