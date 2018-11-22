class AuditFeedbackJob < SpreadsheetWriterJob
  WORKSHEET_POSITION = 4
  queue_as :audit_feedback

  def perform(data)
    return unless AUDIT_SPREADSHEET_ID
    write_row(data, WORKSHEET_POSITION)
  end
end
