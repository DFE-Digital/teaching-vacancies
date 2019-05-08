require 'export_to_spreadsheet'

class AddVacancyPublishFeedbackToSpreadsheet < ExportToSpreadsheet
  def initialize
    @category = 'vacancy_publish_feedback'
  end

  private

  def query
    VacancyPublishFeedback.all
  end
end