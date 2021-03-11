class Jobseekers::JobApplicationMailer < Jobseekers::BaseMailer
  def application_submitted(job_application)
    @vacancy = job_application.vacancy
    @organisation_name = @vacancy.parent_organisation.name
    @contact_email = @vacancy.contact_email
    @jobseeker = job_application.jobseeker

    @template = NOTIFY_JOBSEEKER_APPLICATION_SUBMITTED_CONFIRMATION_TEMPLATE
    @to = job_application.jobseeker.email

    view_mail(@template, to: @to, subject: I18n.t("jobseekers.job_application_mailer.application_submitted.subject"))
  end
end
