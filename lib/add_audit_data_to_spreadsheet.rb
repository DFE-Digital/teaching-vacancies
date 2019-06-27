require 'export_to_spreadsheet'

class AddAuditDataToSpreadsheet < ExportToSpreadsheet
  private

  def query
    AuditData.where(category: @category)
  end

  def present(audit_data)
    audit_data.to_row
  end
end
