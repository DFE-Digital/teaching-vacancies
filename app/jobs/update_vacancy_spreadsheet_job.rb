class UpdateVacancySpreadsheetJob < SpreadsheetWriterJob
  WORKSHEET_POSITION = 0
  queue_as :update_vacancy_spreadsheet

  def perform(vacancy_id)
    return unless AUDIT_SPREADSHEET_ID

    vacancy = Vacancy.find(vacancy_id)
    row = VacancyPresenter.new(vacancy).to_row
    write_row(row, WORKSHEET_POSITION)
  end
end
