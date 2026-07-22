module Jobseekers
class JobApplications::BreaksController < BaseController
  before_action :set_job_application
  before_action :set_employment_break, only: %i[edit update confirm_destroy destroy]

  def new
    form_attributes = if params[:started_on] && params[:ended_on]
                        { started_on: Date.parse(params[:started_on]), ended_on: Date.parse(params[:ended_on]) }
                      else
                        # :nocov:
                        {}
                        # :nocov:
                      end
    @employment_break = @job_application.employment_breaks.build(form_attributes)
  end

  def edit; end

  def create
    @employment_break = @job_application.employment_breaks.build(employment_break_params)
    if @employment_break.save
      redirect_to back_path
    else
      render :new
    end
  end

  def update
    if @employment_break.update(employment_break_params)
      redirect_to back_path
    else
      render :edit
    end
  end

  def confirm_destroy; end

  def destroy
    @employment_break.destroy
    redirect_to back_path
  end

  private

  def back_path
    @back_path ||= jobseekers_job_application_build_path(@job_application, :employment_history)
  end

  def set_employment_break
    @employment_break = @job_application.employment_breaks.find(params[:id] || params[:break_id])
  end

  def employment_break_params
    params.expect(jobseekers_break_form: %i[reason_for_break started_on ended_on])
          .merge("started_on(3i)" => "1", "ended_on(3i)" => "1")
  end

  def set_job_application
    @job_application = current_jobseeker.job_applications.draft.find(params[:job_application_id])
  end
end
end
