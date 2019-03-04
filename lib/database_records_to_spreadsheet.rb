require 'spreadsheet_writer'

class DatabaseRecordsToSpreadsheet
  def initialize(category)
    @category = category
  end

  def run!
    worksheet.append_rows(data_array)
  end

  private

  def worksheet_position
    AUDIT_GIDS[category.to_sym]
  end

  def results
    @results ||= begin
      query.where('created_at > ?', last_updated) unless last_updated.nil?
      results.order(:created_at)
    end
  end

  def worksheet
    @worksheet ||= Spreadsheet::Writer.new(AUDIT_SPREADSHEET_ID, worksheet_position, true)
  end

  def last_updated
    return nil if worksheet.last_row.nil?
    Time.zone.parse(worksheet.last_row[0])
  end

  attr_reader :category
end