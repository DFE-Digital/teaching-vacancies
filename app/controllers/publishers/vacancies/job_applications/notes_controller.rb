class Publishers::Vacancies::JobApplications::NotesController < Publishers::Vacancies::JobApplications::BaseController
  def index
    @notes_form = Publishers::JobApplication::NotesForm.new
  end

  def create
    @notes_form = Publishers::JobApplication::NotesForm.new(notes_form_params)

    if @notes_form.valid?
      Note.create(notes_form_params.merge(job_application: job_application, publisher: current_publisher))
      flash[:success] = "A note has been added"
      redirect_to organisation_job_job_application_notes_path
    else
      render :index
    end
  end

  private

  def notes_form_params
    params[:publishers_job_application_notes_form].permit(:content)
  end
end
