class Jobseekers::UploadedJobApplications::UploadApplicationFormsController < Jobseekers::JobApplications::BaseController
  before_action :set_job_application, except: :download_submitted_form

  def edit
    @form = Jobseekers::UploadedJobApplication::UploadApplicationFormForm.new
  end

  def update
    @form = Jobseekers::UploadedJobApplication::UploadApplicationFormForm.new(form_params)
    if @form.valid?
      if @form.application_form
        @job_application.application_form.attach(@form.application_form)
      end
      @job_application.update!(update_params)
      redirect_to jobseekers_job_application_apply_path(@job_application)
    else
      render :edit
    end
  end

  def download_submitted_form
    submitted_job_application = current_jobseeker.job_applications.after_submission.find_by(id: params[:uploaded_job_application_id])
    if submitted_job_application&.application_form.present?
      send_data(
        submitted_job_application.application_form.download,
        filename: submitted_job_application.application_form.filename.to_s,
        type: submitted_job_application.application_form.content_type,
        disposition: "inline",
      )
    else
      redirect_to jobseekers_job_applications_path, alert: I18n.t("jobseekers.uploaded_job_applications.upload_application_form.not_authorized_to_download")
    end
  end

  private

  def set_job_application
    @job_application = current_jobseeker.job_applications.draft.find(params[:uploaded_job_application_id])
  end

  def form_params
    params.require(:jobseekers_uploaded_job_application_upload_application_form_form)
          .permit(:application_form, :upload_application_form_section_completed)
  end

  def update_params
    if form_params["upload_application_form_section_completed"] == "false"
      { completed_steps: @job_application.completed_steps - %w[upload_application_form] }
    else
      { completed_steps: (@job_application.completed_steps + %w[upload_application_form]).uniq }
    end
  end
end
