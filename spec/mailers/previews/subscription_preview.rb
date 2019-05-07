# Preview all emails at http://localhost:3000/rails/mailers/subscription
class SubscriptionPreview < ActionMailer::Preview
  def confirmation
    SubscriptionMailer.confirmation(subscription.id)
  end

  def first_expiry_warning
    SubscriptionMailer.first_expiry_warning(subscription.id)
  end

  def final_expiry_warning
    SubscriptionMailer.final_expiry_warning(subscription.id)
  end

  private

  def subscription
    Subscription.count.zero? ? FactoryBot.create(:subscription, search_criteria: { subject: 'english' }.to_json) : Subscription.last
  end
end