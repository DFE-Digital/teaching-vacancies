class Jobseekers::MessageMailer < Jobseekers::BaseMailer
  def message_received(message)
    @message = message
    @jobseeker = message.conversation.job_application.jobseeker
    @job_application = message.conversation.job_application
    @vacancy = @job_application.vacancy
    @organisation = @vacancy.organisation

    @subject = if @job_application.status == "unsuccessful"
                 I18n.t("jobseekers.message_mailer.message_received.unsuccessful.subject",
                        job_title: @vacancy.job_title,
                        organisation_name: @organisation.name)
               else
                 I18n.t("jobseekers.message_mailer.message_received.default.subject")
               end

    send_email(to: @jobseeker.email, subject: @subject)
  end
end
