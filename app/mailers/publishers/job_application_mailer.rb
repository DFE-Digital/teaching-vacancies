class Publishers::JobApplicationMailer < Publishers::BaseMailer
  helper VacanciesHelper

  def applications_received(publisher:)
    @template = template
    @publisher = publisher
    @vacancies = publisher.vacancies_with_job_applications_submitted_yesterday
    @to = publisher.email

    @job_applications_count = @vacancies.sum { |vacancy| vacancy.job_applications.submitted_yesterday.count }
    @subject = I18n.t("publishers.job_application_mailer.applications_received.subject", count: @job_applications_count)

    view_mail(@template, to: @to, subject: @subject)
  end

  private

  def email_event_data
    { vacancies_job_applications: vacancies_job_applications }
  end

  def vacancies_job_applications
    @vacancies.each_with_object({}) do |vacancy, hash|
      hash[StringAnonymiser.new(vacancy.id).to_s] =
        vacancy.job_applications.submitted_yesterday.pluck(:id).map { |job_application_id| StringAnonymiser.new(job_application_id).to_s }
    end
  end
end
