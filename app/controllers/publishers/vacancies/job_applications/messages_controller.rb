class Publishers::Vacancies::JobApplications::MessagesController < Publishers::Vacancies::JobApplications::BaseController
  before_action :set_job_application

  def create
    message_form = Publishers::JobApplication::MessagesForm.new(message_form_params)

    if message_form.valid?
      conversation = find_or_create_conversation
      PublisherMessage.create!(content: message_form.content, sender: current_publisher, conversation: conversation)
      redirect_to messages_organisation_job_job_application_path(@vacancy.id, @job_application.id), success: t(".success")
    else
      @tab = "messages"
      @show_form = "true"

      conversation = @job_application.conversations.first
      @messages = if conversation&.messages
                    conversation.messages.order(created_at: :desc)
                  else
                    []
                  end
      @message_form = message_form

      render "publishers/vacancies/job_applications/messages", status: :unprocessable_entity
    end
  end

  private

  def find_or_create_conversation
    @job_application.conversations.first ||
      @job_application.conversations.create!
  end

  def message_form_params
    params[:publishers_job_application_messages_form].permit(:content)
  end
end
