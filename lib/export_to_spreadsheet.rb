require 'spreadsheet_writer'

class ExportToSpreadsheet
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

  def worksheet
    @worksheet ||= Spreadsheet::Writer.new(AUDIT_SPREADSHEET_ID, worksheet_position, true)
  end

  def data_array
    results.map(&method(:present))
  end

  def results
    @results ||= begin
      results = last_updated.nil? ? query : query.where('created_at > ?', last_updated)
      results.order(:created_at)
    end
  end

  def last_updated
    return nil if worksheet.last_row.nil?

    Time.zone.parse(worksheet.last_row[0])
  end

  attr_reader :category
end
