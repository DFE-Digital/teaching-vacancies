class SubscriptionMailer < ApplicationMailer
  def confirmation(subscription_id)
    subscription = Subscription.find(subscription_id)
    @subscription = SubscriptionPresenter.new(subscription)

    view_mail(
      NOTIFY_SUBSCRIPTION_CONFIRMATION_TEMPLATE,
      to: @subscription.email,
      subject: I18n.t("subscription_mailer.confirmation.subject"),
    )
  end

  def update(subscription_id)
    subscription = Subscription.find(subscription_id)
    @subscription = SubscriptionPresenter.new(subscription)

    view_mail(
      NOTIFY_SUBSCRIPTION_UPDATE_TEMPLATE,
      to: @subscription.email,
      subject: I18n.t("subscription_mailer.update.subject"),
    )
  end
end
