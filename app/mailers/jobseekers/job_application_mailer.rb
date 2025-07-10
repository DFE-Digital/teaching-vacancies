class Jobseekers::JobApplicationMailer < Jobseekers::BaseMailer
  def application_submitted(job_application)
    @vacancy = job_application.vacancy
    @organisation_name = @vacancy.organisation_name
    @contact_email = @vacancy.contact_email

    send_email(to: job_application.email_address, subject: I18n.t("jobseekers.job_application_mailer.application_submitted.subject"))
  end

  def job_listing_ended_early(job_application, vacancy)
    @job_application = job_application
    @jobseeker = job_application.jobseeker
    @vacancy = vacancy

    send_email(to: @jobseeker.email, subject: t(".subject", job_title: @vacancy.job_title, organisation_name: @vacancy.organisation_name))
  end

  def declarations(job_application)
    @job_application = job_application
    @vacancy = @job_application.vacancy
    @organisation_name = @vacancy.organisation_name

    send_email(to: job_application.email_address, subject: t(".subject", job_title: @vacancy.job_title))
  end
end
