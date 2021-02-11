class AuditExpressInterestEventJob < ActiveJob::Base
  queue_as :low

  def perform(data)
    AuditData.create(category: :interest_expression, data: data)
  end
end
