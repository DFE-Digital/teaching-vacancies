class DeleteOldDraftApplicationsForExpiredVacanciesJob < ApplicationJob
  queue_as :low

  def perform
    JobApplication.joins(:vacancy)
                  .draft
                  .where(job_applications: { updated_at: ...5.years.ago })
                  .merge(PublishedVacancy.expired)
                  .find_each(&:destroy!)
  end
end
