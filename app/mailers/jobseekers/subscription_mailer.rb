class Jobseekers::SubscriptionMailer < Jobseekers::BaseMailer
  helper_method :subscription, :jobseeker

  def confirmation(subscription_id)
    @subscription_id = subscription_id

    @to = subscription.email

    send_email(to: @to, subject: I18n.t("jobseekers.subscription_mailer.confirmation.subject"))
  end

  def update(subscription_id)
    @subscription_id = subscription_id

    @to = subscription.email

    send_email(to: @to, subject: I18n.t("jobseekers.subscription_mailer.update.subject"))
  end

  private

  def dfe_analytics_custom_data
    { subscription_identifier: subscription.id }
  end

  def email_event_prefix
    "jobseeker_subscription"
  end

  def jobseeker
    @jobseeker ||= Jobseeker.find_by(email: subscription.email.downcase)
  end

  def subscription
    @subscription ||= SubscriptionPresenter.new(Subscription.find(@subscription_id))
  end
end
