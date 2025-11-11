module Publishers
  module Vacancies
    class BulkMessagesController < BaseController
      before_action :set_job_applications

      include Wicked::Wizard

      steps :select_template, :send_messages

      def show
        case step
        when :select_template
          session[:template_return_path] = request.original_fullpath
          @message_templates = message_templates.with_rich_text_content_and_embeds
        when :send_messages
          email_template = message_templates.find_by(id: params[:message_template])
          @message = if email_template.present?
                       PublisherMessage.new content: email_template.content
                     else
                       PublisherMessage.new
                     end
        end
        render_wizard
      end

      # we never call update apart from in the send_messages state
      def update
        send_messages_for(@job_applications)
        redirect_to_next next_step
      end

      private

      def send_messages_for(job_applications)
        job_applications.each do |job_application|
          conversation = job_application.conversations.build
          conversation.publisher_messages.build(send_message_params.merge(sender: current_publisher))
          conversation.save!
        end
      end

      def set_job_applications
        @batch_email = vacancy.job_application_batches.find(params[:job_application_batch_id])
        @job_applications = @batch_email.job_applications
      end

      def message_templates
        current_publisher.message_templates
      end

      def send_message_params
        params.expect(publisher_message: %i[content])
      end
    end
  end
end
