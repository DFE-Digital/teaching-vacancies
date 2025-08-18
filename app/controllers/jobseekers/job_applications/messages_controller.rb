class Jobseekers::JobApplications::MessagesController < Jobseekers::JobApplications::BaseController
  before_action :set_job_application
  before_action :ensure_conversation_exists, only: [:create]

  def create
    conversation = @job_application.conversations.first
    message = conversation.messages.build(message_form_params.merge(sender: current_jobseeker))

    if message.valid?
      message.save!
      redirect_to jobseekers_job_application_path(@job_application, tab: "messages"), success: t("publishers.vacancies.job_applications.messages.create.success")
    else
      redirect_to jobseekers_job_application_path(@job_application, tab: "messages"), warning: t("publishers.vacancies.job_applications.messages.create.failure")
    end
  end

  private

  def ensure_conversation_exists
    unless @job_application.conversations.exists?
      redirect_to jobseekers_job_application_path(@job_application, tab: "messages"), warning: "No conversation exists to reply to"
    end
  end

  def message_form_params
    params[:message].permit(:content)
  end

  def set_job_application
    @job_application = current_jobseeker.job_applications.find(params[:job_application_id])
  end
end
