class Jobseekers::JobApplications::MessagesController < Jobseekers::JobApplications::BaseController
  before_action :set_job_application
  helper_method :vacancy

  def create
    message_form = Publishers::JobApplication::MessagesForm.new(message_form_params)

    if message_form.valid?
      conversation = find_or_create_conversation
      JobseekerMessage.create!(content: message_form.content, sender: current_jobseeker, conversation: conversation)
      redirect_to jobseekers_job_application_path(@job_application, tab: "messages"), success: t("publishers.vacancies.job_applications.messages.create.success")
    else
      @tab = "messages"

      conversation = @job_application.conversations.first
      @messages = conversation.messages.order(created_at: :desc)
      @message_form = message_form

      render "jobseekers/job_applications/show", status: :unprocessable_entity
    end
  end

  private

  def message_form_params
    params[:publishers_job_application_messages_form].permit(:content)
  end

  def set_job_application
    @job_application = current_jobseeker.job_applications.find(params[:job_application_id])
  end

  def vacancy
    @job_application.vacancy
  end

  def find_or_create_conversation
    @job_application.conversations.first ||
      @job_application.conversations.create!(title: Conversation.default_title_for(@job_application))
  end
end
