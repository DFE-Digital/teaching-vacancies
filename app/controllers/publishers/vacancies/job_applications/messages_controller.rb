class Publishers::Vacancies::JobApplications::MessagesController < Publishers::Vacancies::JobApplications::BaseController
  before_action :set_job_application

  def create
    conversation = @job_application.conversations.first || @job_application.conversations.build
    @message = conversation.publisher_messages.build(message_form_params)

    # Saving through the conversation means a new conversation is only persisted alongside a valid message
    if conversation.save
      redirect_to messages_organisation_job_job_application_path(@vacancy.id, @job_application.id), success: t(".success")
    else
      @tab = "messages"
      @show_form = "true"
      @messages = conversation.persisted? ? conversation.messages.order(created_at: :desc) : []

      render "publishers/vacancies/job_applications/messages", status: :unprocessable_content
    end
  end

  private

  def message_form_params
    params.expect(publisher_message: %i[content]).merge(sender: current_publisher)
  end
end
