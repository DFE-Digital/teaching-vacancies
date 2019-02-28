require 'export_to_spreadsheet'

class AddFeedbackToSpreadsheet < ExportToSpreadsheet
  private

  def query
    Feedback.all
  end
end