class Publishers::Vacancies::JobApplications::NotesController < Publishers::Vacancies::JobApplications::BaseController
  before_action :set_job_application

  def destroy
    note = @job_application.notes.find(params[:id])
    note.discard
    redirect_to redirect_path, success: t(".success")
  end

  private

  def redirect_path
    params[:return_to].presence || organisation_job_job_application_path(id: @job_application.id)
  end
end
