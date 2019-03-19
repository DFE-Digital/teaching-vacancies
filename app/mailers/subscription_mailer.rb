class SubscriptionMailer < ApplicationMailer
  def confirmation(subscription_id)
    subscription = Subscription.find(subscription_id)

    @subscription_reference = subscription.reference
    @search_criteria = SubscriptionPresenter.new(subscription).filtered_search_criteria
    @expires_on = subscription.expires_on
    @unsubscribe_token = subscription.token

    view_mail(
      NOTIFY_SUBSCRIPTION_CONFIRMATION_TEMPLATE,
      to: subscription.email,
      subject: "Teaching Vacancies subscription confirmation: #{subscription.reference}",
    )
  end
end
