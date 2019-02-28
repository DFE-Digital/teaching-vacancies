require 'export_to_spreadsheet'

class AddAuditDataToSpreadsheet < ExportToSpreadsheet
  private

  def query
    AuditData.where(category: @category)
  end
end