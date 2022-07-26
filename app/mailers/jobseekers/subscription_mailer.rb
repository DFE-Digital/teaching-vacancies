class Jobseekers::SubscriptionMailer < Jobseekers::BaseMailer
  helper_method :subscription, :jobseeker

  def confirmation(subscription_id)
    @subscription_id = subscription_id

    @template = general_template
    @to = subscription.email

    view_mail(@template, to: @to, subject: I18n.t("jobseekers.subscription_mailer.confirmation.subject"))
  end

  def update(subscription_id)
    @subscription_id = subscription_id

    @template = general_template
    @to = subscription.email

    view_mail(@template, to: @to, subject: I18n.t("jobseekers.subscription_mailer.update.subject"))
  end

  private

  def email_event_data
    { subscription_identifier: StringAnonymiser.new(subscription.id) }
  end

  def email_event_prefix
    "jobseeker_subscription"
  end

  def jobseeker
    @jobseeker ||= Jobseeker.find_by(email: subscription.email)
  end

  def subscription
    @subscription ||= SubscriptionPresenter.new(Subscription.find(@subscription_id))
  end
end
