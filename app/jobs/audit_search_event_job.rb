class AuditSearchEventJob < SpreadsheetWriterJob
  queue_as :audit_search_event

  def perform(data)
    AuditData.create(category: :search_event, data: data)
  end
end
