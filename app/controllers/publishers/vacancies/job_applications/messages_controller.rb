class Publishers::Vacancies::JobApplications::MessagesController < Publishers::Vacancies::JobApplications::BaseController
  before_action :set_job_application

  def create
    @message = @job_application.messages.build(message_params)
    @message.sender = current_publisher

    if @message.save
      redirect_to organisation_job_job_application_path(id: @job_application.id, tab: "messages"), success: t(".success")
    else
      redirect_to organisation_job_job_application_path(id: @job_application.id, tab: "messages"), warning: t(".failure")
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end