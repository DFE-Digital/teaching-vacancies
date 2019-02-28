require 'export_to_spreadsheet'

class AddFeedbackToSpreadsheet < ExportToSpreadsheet
  def initialize
    @category = 'feedback'
  end

  private

  def query
    Feedback.all
  end
end