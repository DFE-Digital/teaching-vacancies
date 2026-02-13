class Jobseekers::JobApplications::MessagesController < Jobseekers::JobApplications::BaseController
  before_action :set_job_application
  helper_method :vacancy

  def create
    conversation = find_or_create_conversation
    @message = conversation.jobseeker_messages.build(message_form_params)

    if @message.save
      redirect_to jobseekers_job_application_path(@job_application, tab: "messages"), success: t("publishers.vacancies.job_applications.messages.create.success")
    else
      @tab = "messages"
      @show_form = "true"

      conversation = @job_application.conversations.first
      @messages = conversation.messages.order(created_at: :desc)

      render "jobseekers/job_applications/show", status: :unprocessable_entity
    end
  end

  private

  def message_form_params
    params.fetch(:jobseeker_message, {}).permit(:content).merge(sender: current_jobseeker)
  end

  def set_job_application
    @job_application = current_jobseeker.job_applications.find(params[:job_application_id])
  end

  def vacancy
    @job_application.vacancy
  end

  def find_or_create_conversation
    @job_application.conversations.first ||
      @job_application.conversations.create!
  end
end
