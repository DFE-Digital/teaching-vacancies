module Publishers
  class BatchRejectionMailer < AmazonSesMailer
    include ActionView::Helpers::AssetTagHelper

    def send_rejection(from:, subject:, content:, job_application:, cc:, logo_org:)
      @from = from
      @content = content
      @name = job_application.first_name
      @logo_path = image_tag(logo_org.logo) if logo_org
      send_email(cc: cc, to: job_application.email_address, subject: subject)
    end

    include MailerDfeAnalytics
  end
end
