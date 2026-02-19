class Publishers::Vacancies::JobApplications::MessagesController < Publishers::Vacancies::JobApplications::BaseController
  before_action :set_job_application

  def create
    conversation = find_or_create_conversation
    @message = conversation.publisher_messages.build(message_form_params)

    if @message.save
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

      render "publishers/vacancies/job_applications/messages", status: :unprocessable_entity
    end
  end

  private

  def find_or_create_conversation
    @job_application.conversations.first ||
      @job_application.conversations.create!
  end

  def message_form_params
    params.expect(publisher_message: %i[content]).merge(sender: current_publisher)
  end
end
