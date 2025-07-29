class Publishers::Vacancies::JobApplications::NotesController < Publishers::Vacancies::JobApplications::BaseController
  before_action :set_job_application

  def create
    @notes_form = Publishers::JobApplication::NotesForm.new(notes_form_params)

    if @notes_form.valid?
      Note.create(notes_attributes)
      redirect_to redirect_path, success: t(".success")
    else
      redirect_to redirect_path, warning: t(".failure")
    end
  end

  def destroy
    note = @job_application.notes.find(params[:id])
    note.destroy
    redirect_to redirect_path, success: t(".success")
  end

  private

  def redirect_path
    if request.referer&.include?("reference_requests")
      # Extract reference_request_id from the referer URL (UUID format)
      if match = request.referer.match(/reference_requests\/([a-f0-9-]+)/)
        reference_request_id = match[1]
        organisation_job_job_application_reference_request_path(vacancy.id, @job_application.id, reference_request_id)
      else
        organisation_job_job_application_path(id: @job_application.id)
      end
    elsif request.referer&.include?("self_disclosure")
      organisation_job_job_application_self_disclosure_path(vacancy.id, @job_application.id)
    else
      organisation_job_job_application_path(id: @job_application.id)
    end
  end

  def notes_attributes
    notes_form_params.merge(job_application: @job_application, publisher: current_publisher)
  end

  def notes_form_params
    params[:publishers_job_application_notes_form].permit(:content)
  end
end
