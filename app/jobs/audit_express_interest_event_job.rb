class AuditExpressInterestEventJob < ApplicationJob
  queue_as :audit_express_interest_event

  def perform(data)
    AuditData.create(category: :interest_expression, data: data)
  end
end
