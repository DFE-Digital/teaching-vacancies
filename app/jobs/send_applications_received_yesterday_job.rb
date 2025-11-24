class SendApplicationsReceivedYesterdayJob < ApplicationJob
  queue_as :low

  def perform
    publishers_with_vacancies_with_applications_submitted_yesterday.each do |publisher|
      next unless publisher.email?

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
end
