require 'spreadsheet_writer'

class SpreadsheetWriterJob < ApplicationJob
  queue_as :google_spreadsheet_event

  def perform(data)
    return unless AUDIT_SPREADSHEET_ID
    write_row(data)
  end

  private

  def write_row(row, worksheet_position = 0)
    worksheet = Spreadsheet::Writer.new(AUDIT_SPREADSHEET_ID, worksheet_position)
    worksheet.append(row)
  end
end
