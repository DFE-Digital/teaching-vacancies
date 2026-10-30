class DeleteUnconfirmedSubscriptionsJob < ApplicationJob
  queue_as :low

  def perform
    Subscription.unconfirmed_after_governance_email.find_each(&:discard)
  end
end
