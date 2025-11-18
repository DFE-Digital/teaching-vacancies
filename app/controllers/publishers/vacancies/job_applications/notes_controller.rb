class Publishers::Vacancies::JobApplications::NotesController < Publishers::Vacancies::JobApplications::BaseController
  before_action :set_job_application

  def destroy
    note = @job_application.notes.find(params[:id])
    note.discard
    redirect_to redirect_path, success: t(".success")
  end

  private

  def notes_attributes
    notes_form_params.merge(job_application: @job_application, publisher: current_publisher)
  end

  def notes_form_params
    params[:publishers_job_application_notes_form].permit(:content)
  end

  def redirect_path
    params[:return_to].presence || organisation_job_job_application_path(id: @job_application.id)
  end
end
