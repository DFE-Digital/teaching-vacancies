class ExportExpiredVacanciesSinceYesterdayToDwpFindAJobServiceJob < ApplicationJob
  queue_as :default

  def perform
    return if DisableExpensiveJobs.enabled?

    Vacancies::Export::DwpFindAJob::ExpiredAndDeleted::Upload.new(25.hours.ago).call
  end
end
