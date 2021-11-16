class RemoveExpiredVacanciesFromGoogleIndexJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info("Removing expired jobs from Google index")
    Vacancy.expired.where(google_index_removed: false).limit(500).each do |vacancy|
      RemoveGoogleIndexQueueJob.perform_now(Rails.application.routes.url_helpers.job_url(vacancy))
      vacancy.update_column(:google_index_removed, true)
    end
    Rails.logger.info("Finished removing expired jobs from Google index")
  end
end
