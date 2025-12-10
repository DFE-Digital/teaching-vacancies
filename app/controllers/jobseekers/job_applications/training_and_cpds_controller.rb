class Jobseekers::JobApplications::TrainingAndCpdsController < Jobseekers::BaseController
  before_action :set_job_application, only: %i[create edit new update destroy]
  before_action :set_training_and_cpd, only: %i[edit update destroy]

  def new
    @form = Jobseekers::TrainingAndCpdForm.new({})
  end

  def edit
    @form = Jobseekers::TrainingAndCpdForm.new(@training_and_cpd.slice(:name, :provider, :grade, :year_awarded, :course_length))
  end

  def create
    @form = Jobseekers::TrainingAndCpdForm.new(training_and_cpd_form_params)
    if @form.valid?
      @job_application.training_and_cpds.create!(training_and_cpd_form_params)
      redirect_to back_path
    else
      render :new
    end
  end

  def update
    @form = Jobseekers::TrainingAndCpdForm.new(training_and_cpd_form_params)
    if @form.valid?
      @training_and_cpd.update!(training_and_cpd_form_params)
      redirect_to back_path
    else
      # :nocov:
      render :edit
      # :nocov:
    end
  end

  def destroy
    @training_and_cpd.destroy!
    redirect_to back_path, success: t(".success")
  end

  private

  def training_and_cpd_form_params
    params.expect(jobseekers_training_and_cpd_form: %i[name provider grade year_awarded course_length])
  end

  def set_training_and_cpd
    @training_and_cpd = @job_application.training_and_cpds.find(params[:id] || params[:training_and_cpd_id])
  end

  def set_job_application
    @job_application = current_jobseeker.job_applications.draft.find(params[:job_application_id])
  end

  def back_path
    @back_path ||= jobseekers_job_application_build_path(@job_application, :training_and_cpds)
  end
end
