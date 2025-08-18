class Publishers::Vacancies::JobApplications::MessagesController < Publishers::Vacancies::JobApplications::BaseController
  before_action :set_job_application

  def create
    conversation = find_or_create_conversation
    message = conversation.messages.build(message_form_params.merge(sender: current_publisher))

    if message.valid?
      conversation.save! unless conversation.persisted?
      message.save!
      redirect_to organisation_job_job_application_path(@vacancy.id, @job_application.id, tab: "messages"), success: t(".success")
    else
      redirect_to organisation_job_job_application_path(@vacancy.id, @job_application.id, tab: "messages"), warning: t(".failure")
    end
  end

  private

  def find_or_create_conversation
    @job_application.conversations.first ||
      @job_application.conversations.build(title: Conversation.default_title_for(@job_application))
  end

  def message_form_params
    params[:message].permit(:content)
  end
end
