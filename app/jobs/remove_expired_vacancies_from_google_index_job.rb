include Rails.application.routes.url_helpers

class RemoveExpiredVacanciesFromGoogleIndexJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info("Removing expired jobs from Google index")
    Vacancy.expired.find_each do |vacancy|
      RemoveGoogleIndexQueueJob.perform_now(Rails.application.routes.url_helpers.job_url(vacancy))
    end
    Rails.logger.info("Finished removing expired jobs from Google index")
  end
end
