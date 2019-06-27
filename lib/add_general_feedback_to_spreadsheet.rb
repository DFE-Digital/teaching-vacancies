require 'export_to_spreadsheet'

class AddGeneralFeedbackToSpreadsheet < ExportToSpreadsheet
  def initialize
    @category = 'general_feedback'
  end

  private

  def query
    GeneralFeedback.all
  end

  def present(general_feedback)
    general_feedback.to_row
  end
end
