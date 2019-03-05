class AuditTocAcceptanceEventJob < SpreadsheetWriterJob
  WORKSHEET_POSITION = 5
  queue_as :audit_toc_acceptance_event

  def perform(data)
    return unless AUDIT_SPREADSHEET_ID

    write_row(data, WORKSHEET_POSITION)
  end
end
