class Jobseekers::VacancyMailer < Jobseekers::BaseMailer
  def draft_application_only(job_application)
    @job_application = job_application
    @vacancy = job_application.vacancy
    @to = job_application.email

    view_mail(template, to: @to,
                        subject: I18n.t("jobseekers.vacancy_mailer.draft_application_only.subject", date: @vacancy.expires_at.to_date, job_title: job_application.vacancy.job_title))
  end
end
