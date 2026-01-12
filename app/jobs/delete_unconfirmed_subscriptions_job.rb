class DeleteUnconfirmedSubscriptionsJob < ApplicationJob
  queue_as :low

  def perform
    subscriptions_to_delete.find_each(&:destroy)
  end

  private

  def subscriptions_to_delete
    Subscription
      .where("deletion_warning_email_sent_at < ?", 1.month.ago)
      .where.not(deletion_warning_email_sent_at: nil)
      .where(unsubscribed_at: nil)
  end
end
