class ExportVacanciesClosedEarlySinceYesterdayToDwpFindAJobServiceJob < ApplicationJob
  queue_as :default

  def perform
    return if DisableIntegrations.enabled?

    Vacancies::Export::DwpFindAJob::ClosedEarly.new(25.hours.ago).call
  end
end
