class Publishers::JobApplicationMailer < Publishers::BaseMailer
  helper VacanciesHelper

  def applications_received(publisher:)
    @publisher = publisher
    @vacancies = publisher.vacancies_with_job_applications_submitted_yesterday

    @job_applications_count = @vacancies.sum { |vacancy| vacancy.job_applications.submitted_yesterday.count }
    @subject = I18n.t("publishers.job_application_mailer.applications_received.subject", count: @job_applications_count)

    send_email(to: publisher.email, subject: @subject)
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
