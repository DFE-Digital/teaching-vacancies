# Preview all emails at http://localhost:3000/rails/mailers/subscription
class SubscriptionPreview < ActionMailer::Preview
  def confirmation
    SubscriptionMailer.confirmation(subscription.id)
  end

  def first_expiry_warning
    SubscriptionMailer.first_expiry_warning(subscription.id)
  end

  private

  def subscription
    Subscription.count.zero? ? FactoryBot.create(:subscription) : Subscription.last
  end
end