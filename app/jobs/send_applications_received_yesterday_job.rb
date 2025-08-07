class SendApplicationsReceivedYesterdayJob < ApplicationJob
  queue_as :low

  def perform
    vacancies_grouped_by_recipient_email.each do |recipient_email, vacancies|
      Publishers::JobApplicationMailer.applications_received(vacancies: vacancies, recipient_email: recipient_email).deliver_later
      Rails.logger.info("Sidekiq: Sending job applications received yesterday for #{vacancies.count} vacancies to #{recipient_email}")
    end
  end

  private

  def vacancies_grouped_by_recipient_email
    vacancies_with_recipient_emails.group_by(&:recipient_email)
  end

  def vacancies_with_recipient_emails
    Vacancy.distinct
           .includes(:publisher)
           .joins(:job_applications)
           .where("DATE(job_applications.submitted_at) = ? AND job_applications.status = ?", Date.yesterday, 1)
           .where("COALESCE(NULLIF(vacancies.contact_email, ''), publishers.email) IS NOT NULL")
           .select("vacancies.*, COALESCE(NULLIF(vacancies.contact_email, ''), publishers.email) as recipient_email")
           .joins(:publisher)
  end
end
