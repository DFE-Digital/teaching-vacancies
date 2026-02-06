class Publishers::Vacancies::JobApplications::NotesController < Publishers::Vacancies::JobApplications::BaseController
  before_action :set_job_application

  def create
    @note = @job_application.notes.create(note_params)

    if @note.persisted?
      redirect_to redirect_path, success: t(".success")
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(@note, partial: "shared/publishers/note", locals: { note: @note, return_to_url: params[:return_to] })
        end
        format.html do
          flash[:error] = @note.errors.full_messages
          redirect_to redirect_path, warning: t(".failure")
        end
      end
    end
  end

  def destroy
    note = @job_application.notes.find(params[:id])
    note.discard
    redirect_to redirect_path, success: t(".success")
  end

  private

  def note_params
    params[:note].permit(:content).merge(publisher: current_publisher)
  end

  def redirect_path
    params[:return_to].presence || organisation_job_job_application_path(id: @job_application.id)
  end
end
