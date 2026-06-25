class ExportVacanciesPublishedAndUpdatedSinceYesterdayToDwpFindAJobServiceJob < SidekiqJob
  queue_as :default

  def perform
    return if DisableIntegrations.enabled?

    Vacancies::Export::DwpFindAJob::PublishedAndUpdated.new(25.hours.ago).call
  end
end
