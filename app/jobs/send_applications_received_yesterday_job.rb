class SendApplicationsReceivedYesterdayJob < ApplicationJob
  queue_as :low

  def perform
    publishers_with_vacancies_with_applications_submitted_yesterday.each do |publisher|
      next unless publisher.email?

      Publishers::JobApplicationMailer.applications_received(publisher:).deliver_later
      Rails.logger.info("Sidekiq: Sending job applications received yesterday for publisher id: #{publisher.id}")
    end
  end

  private

  def publishers_with_vacancies_with_applications_submitted_yesterday
    Publisher.distinct
             .joins(vacancies: :job_applications)
             .where("DATE(job_applications.submitted_at) = ? AND job_applications.status = ?", Date.yesterday, 1)
  end
end
