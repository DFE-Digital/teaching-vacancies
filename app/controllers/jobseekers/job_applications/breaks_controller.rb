class Jobseekers::JobApplications::BreaksController < Jobseekers::BaseController
  helper_method :back_path, :employment_break, :form, :job_application

  def create
    if form.valid?
      job_application.employments.break.create(employment_break_params)
      redirect_to back_path
    else
      render :new
    end
  end

  def update
    if form.valid?
      employment_break.update(employment_break_params)
      redirect_to back_path
    else
      render :edit
    end
  end

  def destroy
    employment_break.destroy
    redirect_to back_path
  end

  private

  def back_path
    @back_path ||= jobseekers_job_application_build_path(job_application, :employment_history)
  end

  def employment_break
    job_application.employments.break.find(params[:id] || params[:break_id])
  end

  def employment_break_params
    params.require(:jobseekers_break_form)
          .permit(:reason_for_break, :started_on, :ended_on)
          .merge("started_on(3i)" => "1", "ended_on(3i)" => "1")
  end

  def form
    @form ||= Jobseekers::BreakForm.new(form_attributes)
  end

  def form_attributes
    case action_name
    when "new"
      if params[:started_on] && params[:ended_on]
        { started_on: Date.parse(params[:started_on]), ended_on: Date.parse(params[:ended_on]) }
      else
        {}
      end
    when "edit"
      employment_break.slice(:reason_for_break, :started_on, :ended_on)
    when "create", "update"
      employment_break_params
    end
  end

  def job_application
    @job_application ||= current_jobseeker.job_applications.draft.find(params[:job_application_id])
  end
end
