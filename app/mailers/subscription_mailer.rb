class SubscriptionMailer < ApplicationMailer
  def confirmation(subscription_id)
    subscription = Subscription.find(subscription_id)
    @subscription = SubscriptionPresenter.new(subscription)

    view_mail(
      NOTIFY_SUBSCRIPTION_CONFIRMATION_TEMPLATE,
      to: @subscription.email,
      subject: I18n.t('job_alerts.confirmation.email.subject', reference: @subscription.reference),
    )
  end
end
