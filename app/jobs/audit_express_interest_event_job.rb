class AuditExpressInterestEventJob < SpreadsheetWriterJob
  WORKSHEET_POSITION = 2
  queue_as :audit_express_interest_event

  def perform(data)
    return unless AUDIT_SPREADSHEET_ID
    write_row(data, WORKSHEET_POSITION)
  end
end
