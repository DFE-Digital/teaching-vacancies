class Jobseekers::JobApplicationMailer < Jobseekers::BaseMailer
  def application_shortlisted(job_application)
    @job_application = job_application
    @vacancy = @job_application.vacancy
    @organisation_name = @vacancy.organisation_name
    @contact_email = @vacancy.contact_email
    @jobseeker = @job_application.jobseeker

    send_email(to: @jobseeker.email, subject: I18n.t("jobseekers.job_application_mailer.application_shortlisted.subject"))
  end

  def application_submitted(job_application)
    @vacancy = job_application.vacancy
    @organisation_name = @vacancy.organisation_name
    @contact_email = @vacancy.contact_email
    @jobseeker = job_application.jobseeker

    send_email(to: @jobseeker.email, subject: I18n.t("jobseekers.job_application_mailer.application_submitted.subject"))
  end

  def application_unsuccessful(job_application)
    @job_application = job_application
    @vacancy = @job_application.vacancy
    @organisation_name = @vacancy.organisation_name
    @contact_email = @vacancy.contact_email
    @jobseeker = @job_application.jobseeker

    send_email(to: @jobseeker.email, subject: I18n.t("jobseekers.job_application_mailer.application_unsuccessful.subject"))
  end

  def job_listing_ended_early(job_application, vacancy)
    @job_application = job_application
    @jobseeker = job_application.jobseeker
    @vacancy = vacancy

    send_email(to: job_application.jobseeker.email, subject: t(".subject", job_title: @vacancy.job_title, organisation_name: @vacancy.organisation_name))
  end
end
