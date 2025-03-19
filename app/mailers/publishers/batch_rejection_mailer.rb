module Publishers
  class BatchRejectionMailer < AmazonSesMailer
    def send_rejection(from:, subject:, content:, job_application:)
      @from = from
      @content = content
      @name = job_application.first_name
      send_email(to: job_application.email_address, subject: subject)
    end

    include MailerDfeAnalytics
  end
end
