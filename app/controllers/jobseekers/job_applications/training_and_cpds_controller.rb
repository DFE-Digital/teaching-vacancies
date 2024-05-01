class Jobseekers::JobApplications::TrainingAndCpdsController < Jobseekers::ProfilesController
  helper_method :back_path, :job_application, :form, :training_and_cpd

  def edit; end

  def new
  end

  def create
    if form.valid?
      job_application.training_and_cpds.create(training_and_cpd_form_params)
      redirect_to back_path
    else
      render :new
    end
  end

  def update
    if form.valid?
      training_and_cpd.update(training_and_cpd_form_params)
      redirect_to back_path
    else
      render :edit
    end
  end

  def confirm_destroy; end

  def destroy
    training_and_cpd.destroy
    redirect_to back_path, success: t(".success")
  end

  def form
    @form ||= Jobseekers::TrainingAndCpdForm.new(form_attributes)
  end

  def form_attributes
    case action_name
    when "new"
      {}
    when "create", "update"
      training_and_cpd_form_params
    when "edit"
      training_and_cpd.slice(:name, :provider, :grade, :year_awarded)
    end
  end

  def training_and_cpd_form_params
    params.require(:jobseekers_training_and_cpd_form)
          .permit(:name, :provider, :grade, :year_awarded)
  end

  def training_and_cpd
    @training_and_cpd ||= job_application.training_and_cpds.find(params[:id] || params[:training_and_cpd_id])
  end

  def job_application
    @job_application ||= current_jobseeker.job_applications.draft.find(params[:job_application_id])
  end

  def back_path
    @back_path ||= jobseekers_job_application_build_path(job_application, :training_and_cpds)
  end
end
