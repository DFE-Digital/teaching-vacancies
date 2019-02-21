require 'spreadsheet_writer'

class AddAuditData
  def initialize(category)
    @category = category
    @worksheet_position = AuditData.categories[category]
  end

  def run!
    worksheet.append_rows(data_array)
  end

  private

  def worksheet
    @worksheet ||= Spreadsheet::Writer.new(AUDIT_SPREADSHEET_ID, @worksheet_position)
  end

  def data_array
    results.map(&:to_row)
  end

  def results
    @results ||= begin
      results = AuditData.where(category: @category)
      results = results.where('created_at > ?', last_updated) unless last_updated.nil?
      results.order(:created_at)
    end
  end

  def last_updated
    return nil if worksheet.last_row.nil?
    Time.zone.parse(worksheet.last_row[0])
  end
end