class SendApplicationsReceivedYesterdayJob < ApplicationJob
  queue_as :low

  def perform
    contact_emails_with_applications_submitted_yesterday.each do |contact_email|
      Publishers::JobApplicationMailer.applications_received(contact_email: contact_email).deliver_later
    end
  end

  private

  def contact_emails_with_applications_submitted_yesterday
    PublishedVacancy.distinct
                    .joins(:job_applications)
                    .merge(JobApplication.submitted_yesterday)
                    .pluck(:contact_email)
                    .compact
  end
end
