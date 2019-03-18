class AuditSearchEventJob < SpreadsheetWriterJob
  WORKSHEET_POSITION = 3
  queue_as :audit_search_event

  def perform(data)
    return if WORKSHEET_POSITION.present? # Temporarily turn off this auditing until we decide what to do with it
    return unless AUDIT_SPREADSHEET_ID

    write_row(data, WORKSHEET_POSITION)
  end
end
