class Publishers::JobApplicationMailer < Publishers::BaseMailer
  helper VacanciesHelper

  def applications_received(contact_email:)
    @publisher = publisher
    @vacancies = Vacancy.distinct
                        .joins(:job_applications)
                        .where("DATE(job_applications.submitted_at) = ? AND job_applications.status = ? AND contact_email = ?", Date.yesterday, 1, contact_email)

    @job_applications_count = @vacancies.sum { |vacancy| vacancy.job_applications.submitted_yesterday.count }
    @subject = I18n.t("publishers.job_application_mailer.applications_received.subject", count: @job_applications_count)

    send_email(to: contact_email, subject: @subject)
  end

  private

  def dfe_analytics_custom_data
    { vacancies_job_applications: vacancies_job_applications }
  end

  def vacancies_job_applications
    @vacancies.each_with_object({}) do |vacancy, hash|
      hash[vacancy.id] = vacancy.job_applications.submitted_yesterday.pluck(:id)
    end
  end
end
