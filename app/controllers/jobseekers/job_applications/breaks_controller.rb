class Jobseekers::JobApplications::BreaksController < Jobseekers::BaseController
  helper_method :back_path, :employment_break, :job_application

  def new
    form_attributes = if params[:started_on] && params[:ended_on]
                        { started_on: Date.parse(params[:started_on]), ended_on: Date.parse(params[:ended_on]) }
                      else
                        {}
                      end
    @form = Jobseekers::BreakForm.new(form_attributes)
  end

  def edit
    @form = Jobseekers::BreakForm.new(employment_break.slice(:reason_for_break, :started_on, :ended_on))
  end

  def create
    @form = Jobseekers::BreakForm.new(employment_break_params)

    if @form.valid?
      job_application.employments.break.create(employment_break_params)
      redirect_to back_path
    else
      render :new
    end
  end

  def update
    @form = Jobseekers::BreakForm.new(employment_break_params)
    if @form.valid?
      employment_break.update(employment_break_params)
      redirect_to back_path
    else
      render :edit
    end
  end

  def confirm_destroy
    @form = Jobseekers::BreakForm.new
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
    params.expect(jobseekers_break_form: %i[reason_for_break started_on ended_on])
          .merge("started_on(3i)" => "1", "ended_on(3i)" => "1")
  end

  def job_application
    @job_application ||= current_jobseeker.job_applications.draft.find(params[:job_application_id])
  end
end
