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
    if params.key?(:reminder)
      @job_application.self_disclosure_request.send_reminder!
      flash[:success] = t("publishers.vacancies.job_applications.self_disclosure.reminder_sent")
    else
      @job_application.self_disclosure_request.received_off_service!
      flash[:success] = t("jobseekers.job_applications.self_disclosure.review.completed.manually_completed")
    end

    redirect_to organisation_job_job_application_self_disclosure_path(@vacancy.id, @job_application.id)
  end

  # def mark_as_received
  #   @job_application.self_disclosure_request.received_off_service!
  #   flash[:success] = t("jobseekers.job_applications.self_disclosure.review.completed.manually_completed")
  #   redirect_to organisation_job_job_application_self_disclosure_path(@vacancy.id, @job_application.id)
  # end
  #
  # def send_reminder_email
  #   @job_application.self_disclosure_request.send_reminder!
  #   flash[:success] = t("publishers.vacancies.job_applications.self_disclosure.reminder_sent")
  #   redirect_to organisation_job_job_application_self_disclosure_path(@vacancy.id, @job_application.id)
  # end
  #
  # def mark_as_complete
  #   @job_application.self_disclosure_request.update!(marked_as_complete: true)
  #   redirect_to organisation_job_job_application_self_disclosure_path(@vacancy.id, @job_application.id)
  # end

  private

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
