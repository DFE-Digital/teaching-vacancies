class UpdateVacancySpreadsheetJob < ApplicationJob
  queue_as :update_vacancy_spreadsheet

  def perform(vacancy_id)
    vacancy = Vacancy.find(vacancy_id)
    _row = vacancy.to_row
  end
end
