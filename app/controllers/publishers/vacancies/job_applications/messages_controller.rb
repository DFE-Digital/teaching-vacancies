class Publishers::Vacancies::JobApplications::MessagesController < Publishers::Vacancies::JobApplications::BaseController
  before_action :set_job_application

  def create
    @message_form = Publishers::JobApplication::MessagesForm.new(message_form_params)

    if @message_form.valid?
      Message.create(message_attributes)
      redirect_to organisation_job_job_application_path(id: @job_application.id, tab: "messages"), success: t(".success")
    else
      redirect_to organisation_job_job_application_path(id: @job_application.id, tab: "messages"), warning: t(".failure")
    end
  end

  private

  def message_attributes
    message_form_params.merge(job_application: @job_application, sender: current_publisher)
  end

  def message_form_params
    params[:publishers_job_application_messages_form].permit(:content)
  end
end