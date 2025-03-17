module Publishers
  class BatchRejectionMailer < AmazonSesMailer
    include ActionView::Helpers::AssetTagHelper

    def send_rejection(from:, subject:, content:, job_application:, bcc:, logo_org:, contact_email:)
      @from = from
      @content = content
      @name = job_application.first_name
      @logo_path = image_tag(logo_org.logo) if logo_org
      @contact_email = contact_email
      send_email(bcc: bcc, to: job_application.email_address, subject: subject)
    end

    include MailerDfeAnalytics
  end
end
