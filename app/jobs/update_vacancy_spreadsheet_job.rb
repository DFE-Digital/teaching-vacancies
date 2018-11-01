require 'spreadsheet_writer'

class UpdateVacancySpreadsheetJob < ApplicationJob
  queue_as :update_vacancy_spreadsheet

  PUBLISHED_VACANCY_SPREADSHEET_ID = ENV['PUBLISHED_VACANCY_SPREADSHEET_ID']

  def perform(vacancy_id)
    return unless PUBLISHED_VACANCY_SPREADSHEET_ID
    vacancy = Vacancy.find(vacancy_id)
    write_row(vacancy)
  end

  private

  def write_row(vacancy)
    row = VacancyPresenter.new(vacancy).to_row
    worksheet = Spreadsheet::Writer.new(PUBLISHED_VACANCY_SPREADSHEET_ID)
    worksheet.append(row)
    Rails.logger.info("Sidekiq: added vacancy #{vacancy.id} to published vacancies sheet")
  end
end
