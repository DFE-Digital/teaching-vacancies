class SendApplicationsReceivedYesterdayJob < ApplicationJob
  queue_as :low

  def perform
    contact_emails_with_applications_submitted_yesterday.each do |contact_email|
      next if contact_email.blank?

      Publishers::JobApplicationMailer.applications_received(publisher, publisher.vacancies_with_job_applications_submitted_yesterday).deliver_later
      Rails.logger.info("Sidekiq: Sending job applications received yesterday for publisher id: #{publisher.id}")
    end
  end

  private

  def publishers_with_vacancies_with_applications_submitted_yesterday
    Publisher.distinct
             .joins(vacancies: :job_applications)
             .merge(JobApplication.submitted)
             .merge(JobApplication.submitted_yesterday)
  end
  
  def contact_emails_with_applications_submitted_yesterday
    PublishedVacancy.distinct
                    .joins(:job_applications)
                    .merge(JobApplication.submitted_yesterday)
                    .pluck(:contact_email)
                    .compact
  end
end
