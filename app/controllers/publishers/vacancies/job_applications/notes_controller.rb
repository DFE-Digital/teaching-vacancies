class Publishers::Vacancies::JobApplications::NotesController < Publishers::Vacancies::JobApplications::BaseController
  def create
    @notes_form = Publishers::JobApplication::NotesForm.new(notes_form_params)

    if @notes_form.valid?
      Note.create(notes_attributes)
      redirect_to organisation_job_job_application_path(id: job_application.id), success: t(".success")
    else
      render :index
    end
  end

  def destroy
    note = job_application.notes.find(params[:id])
    note.destroy
    redirect_to organisation_job_job_application_path(id: job_application.id), success: t(".success")
  end

  private

  def notes_attributes
    notes_form_params.merge(job_application: job_application, publisher: current_publisher)
  end

  def notes_form_params
    params[:publishers_job_application_notes_form].permit(:content)
  end
end
