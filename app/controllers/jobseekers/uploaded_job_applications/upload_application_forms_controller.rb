class Jobseekers::UploadedJobApplications::UploadApplicationFormsController < Jobseekers::JobApplications::BaseController
  before_action :set_job_application

  def edit
    @form = Jobseekers::UploadedJobApplication::UploadApplicationFormForm.new
  end

  def update
    # Skip validation if no new file is submitted, but one is already attached
    if !form_params[:application_form] && @job_application.application_form.attached?
      @form = Jobseekers::UploadedJobApplication::UploadApplicationFormForm.new(
        form_params.to_h.merge(application_form: @job_application.application_form),
      )
      return render :edit if @form.invalid?

      @job_application.update!(update_params)
      return redirect_to jobseekers_job_application_apply_path(@job_application)
    end

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

  def destroy
    @job_application.application_form.purge_later
    @job_application.update!(completed_steps: @job_application.completed_steps - %w[upload_application_form])
    redirect_to edit_jobseekers_uploaded_job_application_upload_application_form_path(@job_application)
  end

  private

  def set_job_application
    @job_application = current_jobseeker.job_applications.draft.find(params[:uploaded_job_application_id])
  end

  def form_params
    params.expect(jobseekers_uploaded_job_application_upload_application_form_form: %i[application_form upload_application_form_section_completed])
  end

  def update_params
    if form_params["upload_application_form_section_completed"] == "false"
      { completed_steps: @job_application.completed_steps - %w[upload_application_form] }
    else
      { completed_steps: (@job_application.completed_steps + %w[upload_application_form]).uniq }
    end
  end
end
