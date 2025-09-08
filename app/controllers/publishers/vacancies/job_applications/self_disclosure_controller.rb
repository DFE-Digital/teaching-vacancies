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

  def update
    @job_application.self_disclosure_request.update!(status: params[:status])

    flash[:success] = t("reference_requests.completed.success_msg") if @job_application.self_disclosure_request.completed?
    redirect_to organisation_job_job_application_self_disclosure_path(vacancy.id, @job_application.id)
  end

  private

  def send_self_disclosure_pdf
    pdf = SelfDisclosurePdfGenerator.new(@self_disclosure).generate

    send_data(
      pdf.render,
      filename: "self_disclosure_#{@self_disclosure.model.id}.pdf",
      disposition: "inline",
    )
  end

  def set_job_application
    @job_application = JobApplication.includes(:self_disclosure_request).find(params[:job_application_id])
  end
end
