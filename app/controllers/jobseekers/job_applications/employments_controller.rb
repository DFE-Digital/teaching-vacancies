class Jobseekers::JobApplications::EmploymentsController < Jobseekers::BaseController
  helper_method :back_path, :employment, :form, :job_application

  def create
    if form.valid?
      job_application.employments.job.create(employment_params)
      redirect_to back_path
    else
      render :new
    end
  end

  def update
    if form.valid?
      employment.update(employment_params)
      redirect_to back_path
    else
      render :edit
    end
  end

  def destroy
    employment.destroy
    redirect_to back_path, success: t(".success")
  end

  private

  def back_path
    @back_path ||= jobseekers_job_application_build_path(job_application, :employment_history)
  end

  def employment
    job_application.employments.job.find(params[:id])
  end

  def employment_params
    params.require(:jobseekers_job_application_details_employment_form)
          .permit(:organisation, :job_title, :subjects, :main_duties, :started_on, :is_current_role, :ended_on, :reason_for_leaving)
          .merge("started_on(3i)" => "1", "ended_on(3i)" => "1")
  end

  def form
    @form ||= Jobseekers::JobApplication::Details::EmploymentForm.new(form_attributes)
  end

  def form_attributes
    case action_name
    when "new"
      {}
    when "edit"
      employment.slice(:organisation, :job_title, :subjects, :main_duties, :started_on, :is_current_role, :ended_on, :reason_for_leaving)
    when "create", "update"
      employment_params
    end
  end

  def job_application
    @job_application ||= current_jobseeker.job_applications.draft.find(params[:job_application_id])
  end
end
