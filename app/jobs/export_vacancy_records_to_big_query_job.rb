require 'export_vacancy_records_to_big_query'

class ExportVacancyRecordsToBigQueryJob < ApplicationJob
  queue_as :export_vacancies

  def perform
    ExportVacancyRecordsToBigQuery.new.run!
  end
end
