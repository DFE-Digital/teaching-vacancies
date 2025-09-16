class Jobseekers::VacancyMailer < Jobseekers::BaseMailer
  def draft_application_only(job_application)
    @job_application = job_application
    @jobseeker = job_application.jobseeker
    @vacancy = job_application.vacancy

    send_email(to: @jobseeker.email,
               subject: I18n.t("jobseekers.vacancy_mailer.draft_application_only.subject", date: @vacancy.expires_at.to_date, job_title: job_application.vacancy.job_title))
  end

  def unapplied_saved_vacancy(vacancy, jobseeker)
    @vacancy = vacancy
    @jobseeker = jobseeker

    send_email(to: jobseeker.email,
               subject: I18n.t("jobseekers.vacancy_mailer.unapplied_saved_vacancy.subject", days: 10, job_title: vacancy.job_title))
  end
end
