module Publishers
  class Vacancies::BatchEmailsController < Vacancies::BaseController
    before_action :set_job_applications

    def select_rejection_template
      session[:template_return_path] = request.original_fullpath
      @message_templates = message_templates.with_rich_text_content_and_embeds
    end

    def prepare_rejection_emails
      email_template = message_templates.find_by(id: params[:message_template])
      @message = if email_template.present?
                   PublisherMessage.new content: email_template.content
                 else
                   PublisherMessage.new
                 end
    end

    def send_rejection_emails
      @job_applications.each do |job_application|
        conversation = job_application.conversations.build
        conversation.publisher_messages.build(send_rejection_emails_params.merge(sender: current_publisher))
        conversation.save!
        job_application.update!(status: :rejected)
      end

      redirect_to organisation_job_job_applications_path(vacancy.id, anchor: :unsuccessful), success: t(".rejections_sent")
    end

    private

    def set_job_applications
      @batch_email = vacancy.job_application_batches.find(params[:id])
      @job_applications = @batch_email.job_applications
    end

    def message_templates
      current_publisher.message_templates.rejection
    end

    def send_rejection_emails_params
      params.expect(publisher_message: %i[content])
    end
  end
end
