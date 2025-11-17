class Publishers::Vacancies::JobApplications::SelfDisclosureController < Publishers::Vacancies::JobApplications::BaseController
  before_action :set_job_application

  def show
    @self_disclosure = SelfDisclosurePresenter.new(@job_application)
    @notes_form = Publishers::JobApplication::NotesForm.new

    respond_to do |format|
      format.html
      format.pdf { send_self_disclosure_pdf }
    end
  end

  def create_note
    @notes_form = Publishers::JobApplication::NotesForm.new(notes_form_params)
    @self_disclosure = SelfDisclosurePresenter.new(@job_application)

    if @notes_form.valid?
      @job_application.notes.create!(notes_form_params.merge(publisher: current_publisher))
      redirect_to organisation_job_job_application_self_disclosure_path(@vacancy.id, @job_application.id)
    else
      render "show"
    end
  end

  def update
    if params.key?(:reminder)
      @job_application.self_disclosure_request.send_reminder!
      flash[:success] = t("publishers.vacancies.job_applications.self_disclosure.reminder_sent")
    elsif params.key?(:completed)
      @job_application.self_disclosure_request.update!(marked_as_complete: true)
    else
      @job_application.self_disclosure_request.received_off_service!
      flash[:success] = t("publishers.vacancies.job_applications.self_disclosure.show.marked_as_received")
    end

    redirect_to organisation_job_job_application_self_disclosure_path(@vacancy.id, @job_application.id)
  end

  private

  def notes_form_params
    params[:publishers_job_application_notes_form].permit(:content)
  end

  def send_self_disclosure_pdf
    pdf = SelfDisclosurePdfGenerator.new(@self_disclosure).generate

    send_data(
      pdf.render,
      filename: "self_disclosure_#{@self_disclosure.model.id}.pdf",
      type: "application/pdf",
      disposition: "inline",
    )
  end

  def set_job_application
    @job_application = JobApplication.includes(:self_disclosure_request).find(params[:job_application_id])
  end
end
