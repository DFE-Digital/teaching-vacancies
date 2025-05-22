class Jobseekers::UploadedJobApplications::UploadApplicationFormsController < Jobseekers::JobApplications::BaseController
  before_action :set_job_application

  helper_method :job_application, :vacancy

  def edit
    @form = Jobseekers::UploadedJobApplication::UploadApplicationFormForm.new
  end

  def update
    @form = Jobseekers::UploadedJobApplication::UploadApplicationFormForm.new(form_params)
    @job_application.application_form.attach(form_params[:upload_application_form])
    if @form.valid?
      if @form.application_form
        @job_application.application_form.purge if @job_application.application_form.attached?
        @job_application.application_form.attach(@form.application_form)
      end
      @job_application.update!(update_params)
      redirect_to jobseekers_job_application_apply_path(@job_application)
    else
      render :edit
    end
  end

  private

  def set_job_application
    @job_application = current_jobseeker.uploaded_job_applications.draft.find(params[:uploaded_job_application_id])
  end

  def form_params
    params.require(:jobseekers_uploaded_job_application_upload_application_form_form)
          .permit(:application_form, :upload_application_form_section_completed)
  end

  def vacancy
    @vacancy ||= job_application.vacancy
  end

  def update_params
    if form_params["upload_application_form_section_completed"] == "false"
      { completed_steps: job_application.completed_steps - %w[upload_application_form] }
    else
      { completed_steps: (@job_application.completed_steps + %w[upload_application_form]).uniq }
    end
  end

  def remove_current_step(steps)
    steps.delete_if { |the_step| the_step == step.to_s }
  end

  # def update
  #   @form = form_class.new(form_class.load_form(job_application).merge(form_params))
  #   if @form.valid?
  #     job_application.update!(update_params)

  #     if redirect_to_review?
  #       redirect_to jobseekers_job_application_review_path(job_application), success: t("messages.jobseekers.job_applications.saved")
  #     elsif steps_complete?
  #       redirect_to jobseekers_job_application_apply_path job_application
  #     else
  #       redirect_to jobseekers_job_application_build_path(job_application, step_process.next_step(step))
  #     end
  #   else
  #     render step
  #   end
  # end
end
