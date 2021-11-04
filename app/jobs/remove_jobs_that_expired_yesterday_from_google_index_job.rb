include Rails.application.routes.url_helpers

class RemoveJobsThatExpiredYesterdayFromGoogleIndexJob < ApplicationJob
  queue_as :default

  def perform
    Vacancy.expired_yesterday.find_each do |vacancy|
      RemoveGoogleIndexQueueJob.perform_now(job_url(vacancy))
    end
    Rails.logger.info("Finished removing jobs that expired on #{Date.yesterday} from Google index")
  end
end
