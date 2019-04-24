require 'export_to_spreadsheet'

class AddGeneralFeedbackToSpreadsheet < ExportToSpreadsheet
  def initialize
    @category = 'general_feedback'
  end

  private

  def query
    GeneralFeedback.all
  end
end