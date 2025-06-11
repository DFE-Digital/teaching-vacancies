class Publishers::Vacancies::JobApplications::SelfDisclosureController < Publishers::Vacancies::JobApplications::BaseController
  before_action :redirect_to_job_application, unless: -> { job_application.self_disclosure_request.present? }

  def show
    @self_disclosure = SelfDisclosurePresenter.new(job_application)
    if @self_disclosure.request.manual?
      @batch = JobApplicationBatch.create!(vacancy_id: job_application.vacancy.id).tap do
        it.batchable_job_applications.create!(job_application: job_application)
      end
    end

    respond_to do |format|
      format.html
      format.pdf { send_self_disclosure_pdf }
    end
  end

  def update
    job_application.self_disclosure_request.manually_completed!

    flash[:success] = t("jobseekers.job_applications.self_disclosure.review.completed.manually_completed")
    redirect_to organisation_job_job_application_self_disclosure_path(vacancy.id, job_application.id)
  end

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

  def job_application
    @job_application ||= JobApplication.includes(:self_disclosure_request).find(params[:job_application_id])
  end

  def redirect_to_job_application
    redirect_to organisation_job_job_application_path(vacancy.id, job_application.id)
  end
end
