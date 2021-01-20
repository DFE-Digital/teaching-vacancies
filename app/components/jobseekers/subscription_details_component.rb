class Jobseekers::SubscriptionDetailsComponent < ViewComponent::Base
  attr_reader :subscription

  def initialize(subscription, current_subscription: false)
    @subscription = subscription
    @current_subscription = current_subscription
  end
end
