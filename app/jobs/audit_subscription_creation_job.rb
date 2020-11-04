class AuditSubscriptionCreationJob < ApplicationJob
  queue_as :audit_subscription_creation

  def perform(data)
    AuditData.create(category: :subscription_creation, data: data)
  end
end
