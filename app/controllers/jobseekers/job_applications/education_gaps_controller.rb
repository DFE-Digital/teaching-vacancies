class Jobseekers::JobApplications::EducationGapsController < Jobseekers::BaseController
  helper_method :back_path, :education_gap, :form, :job_application

  def create
    if form.valid?
      job_application.employments.education_gap.create(education_gap_params)
      redirect_to back_path
    else
      render :new
    end
  end

  def update
    if form.valid?
      education_gap.update(education_gap_params)
      redirect_to back_path
    else
      render :edit
    end
  end

  def destroy
    education_gap.destroy
    redirect_to back_path
  end

  private

  def back_path
    @back_path ||= jobseekers_job_application_build_path(job_application, :employment_history)
  end

  def education_gap
    job_application.employments.education_gap.find(params[:id] || params[:education_gap_id])
  end

  def education_gap_params
    params.expect(jobseekers_break_form: %i[reason_for_break started_on ended_on])
          .merge("started_on(3i)" => "1", "ended_on(3i)" => "1")
  end

  def form
    @form ||= Jobseekers::BreakForm.new(form_attributes)
  end

  def form_attributes
    case action_name
    when "new"
      {}
    when "edit"
      education_gap.slice(:reason_for_break, :started_on, :ended_on)
    when "create", "update"
      education_gap_params
    end
  end

  def job_application
    @job_application ||= current_jobseeker.job_applications.draft.find(params[:job_application_id])
  end
end
