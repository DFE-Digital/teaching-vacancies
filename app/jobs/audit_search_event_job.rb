class AuditSearchEventJob < ApplicationJob
  queue_as :low

  def perform(data)
    AuditData.create(category: :search_event, data: data)
  end
end
