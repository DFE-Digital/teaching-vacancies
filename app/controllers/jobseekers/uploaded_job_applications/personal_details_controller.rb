class Jobseekers::UploadedJobApplications::PersonalDetailsController < Jobseekers::JobApplications::BaseController
  before_action :set_job_application

  def edit
    @form = Jobseekers::UploadedJobApplication::PersonalDetailsForm.new(@job_application.slice(:first_name, :last_name, :email_address, :phone_number, :has_right_to_work_in_uk, :teacher_reference_number))
  end

  def update
    @form = Jobseekers::UploadedJobApplication::PersonalDetailsForm.new(form_params)

    if @form.valid?
      storable_fields = form_params.to_h.symbolize_keys.slice(*Jobseekers::UploadedJobApplication::PersonalDetailsForm.storable_fields)
      @job_application.update!(update_params(storable_fields))
      redirect_to jobseekers_job_application_apply_path(@job_application)
    else
      render :edit
    end
  end

  def update_params(storable_fields)
    if form_params["personal_details_section_completed"] == "false"
      storable_fields.merge(completed_steps: @job_application.completed_steps - %w[personal_details])
    else
      storable_fields.merge(completed_steps: (@job_application.completed_steps + %w[personal_details]).uniq)
    end
  end

  private

  def set_job_application
    @job_application = current_jobseeker.job_applications.draft.find(params[:uploaded_job_application_id])
  end

  def form_params
    params.expect(jobseekers_uploaded_job_application_personal_details_form: %i[first_name last_name phone_number email_address teacher_reference_number personal_details_section_completed has_right_to_work_in_uk])
  end
end
