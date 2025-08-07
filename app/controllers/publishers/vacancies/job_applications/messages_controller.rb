class Publishers::Vacancies::JobApplications::MessagesController < Publishers::Vacancies::JobApplications::BaseController
  before_action :set_job_application

  def create
    @message_form = Publishers::JobApplication::MessagesForm.new(message_form_params)

    if @message_form.valid?
      conversation = find_or_create_conversation
      Message.create(message_attributes.merge(conversation: conversation))
      redirect_to organisation_job_job_application_path(id: @job_application.id, tab: "messages"), success: t(".success")
    else
      redirect_to organisation_job_job_application_path(id: @job_application.id, tab: "messages"), warning: t(".failure")
    end
  end

  private

  def find_or_create_conversation
    @job_application.conversations.first || 
      @job_application.conversations.create!(title: Conversation.default_title_for(@job_application))
  end

  def message_attributes
    message_form_params.merge(sender: current_publisher)
  end

  def message_form_params
    params[:publishers_job_application_messages_form].permit(:content)
  end
end