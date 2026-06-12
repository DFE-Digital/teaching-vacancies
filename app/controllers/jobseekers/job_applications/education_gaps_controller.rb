class Jobseekers::JobApplications::EducationGapsController < Jobseekers::BaseController
  before_action :set_job_application
  before_action :set_education_gap, only: %i[edit update destroy confirm_destroy]

  def new
    @form = Jobseekers::BreakForm.new
  end

  def edit
    @form = Jobseekers::BreakForm.new(@education_gap.slice(:reason_for_break, :started_on, :ended_on))
  end

  def create
    @form = Jobseekers::BreakForm.new(education_gap_params)

    if @form.valid?
      @job_application.employments.education_gap.create!(education_gap_params)
      redirect_to back_path
    else
      render :new
    end
  end

  def update
    @form = Jobseekers::BreakForm.new(education_gap_params)

    if @form.valid?
      @education_gap.update!(education_gap_params)
      redirect_to back_path
    else
      render :edit
    end
  end

  def confirm_destroy
    @form = Jobseekers::BreakForm.new
  end

  def destroy
    @education_gap.destroy!
    redirect_to back_path
  end

  private

  def back_path
    @back_path ||= jobseekers_job_application_build_path(@job_application, :employment_history)
  end

  def set_job_application
    @job_application = current_jobseeker.job_applications.draft.find(params[:job_application_id])
  end

  def set_education_gap
    @education_gap = @job_application.employments.education_gap.find(params[:id] || params[:education_gap_id])
  end

  def education_gap_params
    params.expect(jobseekers_break_form: %i[reason_for_break started_on ended_on])
          .merge("started_on(3i)" => "1", "ended_on(3i)" => "1")
  end
end
