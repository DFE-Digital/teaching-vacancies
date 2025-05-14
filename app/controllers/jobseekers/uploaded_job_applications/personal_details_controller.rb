# app/controllers/jobseekers/uploaded_job_applications/personal_details_controller.rb
class Jobseekers::UploadedJobApplications::PersonalDetailsController < Jobseekers::JobApplications::BaseController
  before_action :set_job_application

  helper_method :job_application, :vacancy

  def edit
    @form = Jobseekers::UploadedJobApplication::PersonalDetailsForm.new(@job_application.slice(:first_name, :last_name, :email_address, :phone_number, :has_right_to_work_in_uk))
  end

  def update
    @form = Jobseekers::UploadedJobApplication::PersonalDetailsForm.new(form_params)
  
    if @form.valid?
      storable_fields = form_params.to_h.symbolize_keys.slice(*Jobseekers::UploadedJobApplication::PersonalDetailsForm.storable_fields)
  
      @job_application.update!(
        storable_fields.merge(
          completed_steps: (@job_application.completed_steps + ["personal_details"]).uniq,
        ),
      )
  
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
    params.require(:jobseekers_uploaded_job_application_personal_details_form).permit(:first_name, :last_name, :phone_number, :email_address, :teacher_reference_number, :personal_details_section_completed, :has_right_to_work_in_uk) # whatever fields you need
  end

  def vacancy
    @vacancy ||= job_application.vacancy
  end
end
