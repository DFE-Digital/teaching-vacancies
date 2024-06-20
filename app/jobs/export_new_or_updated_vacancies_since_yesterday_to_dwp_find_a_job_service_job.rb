class ExportNewOrUpdatedVacanciesSinceYesterdayToDwpFindAJobServiceJob < ApplicationJob
  queue_as :default

  def perform
    return if DisableExpensiveJobs.enabled?

    Vacancies::Export::DwpFindAJob::NewAndEdited::Upload.new(25.hours.ago).call
  end
end
