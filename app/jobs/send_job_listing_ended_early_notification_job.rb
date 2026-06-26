class SendJobListingEndedEarlyNotificationJob < ApplicationJob
  queue_as :default

  def perform(vacancy)
    vacancy.job_applications.draft.each do |job_application|
      Jobseekers::JobApplicationMailer.job_listing_ended_early(job_application, vacancy).deliver_later
    end
  end
end
