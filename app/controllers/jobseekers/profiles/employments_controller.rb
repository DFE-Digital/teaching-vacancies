class Jobseekers::Profiles::EmploymentsController < Jobseekers::ProfilesController
  def new; end

  def edit; end

  def create
    if form.valid?
      profile.employments.create(employment_form_params)
      redirect_to review_jobseekers_profile_work_history_index_path
    else
      render :new
    end
  end

  def update
    if form.valid?
      employment.update(employment_form_params)
      redirect_to review_jobseekers_profile_work_history_index_path, success: t(".success")
    else
      render :edit
    end
  end

  def destroy
    employment.destroy

    redirect_to review_jobseekers_profile_work_history_index_path, success: t(".success")
  end

  def review
    @employments = profile.employments.order(:ended_on)
  end

  private

  helper_method :form

  def form
    @form ||= Jobseekers::Profile::EmploymentForm.new(employment_form_attributes)
  end

  def employment_form_attributes
    case action_name
    when "new"
      {}
    when "edit"
      employment.slice(:organisation, :job_title, :started_on, :current_role, :ended_on, :main_duties, :subjects)
    when "create", "update"
      employment_form_params
    end
  end

  def employment
    profile.employments.find(params[:id])
  end

  def employment_form_params
    params.require(:jobseekers_profile_employment_form)
          .permit(:organisation, :job_title, :started_on, :current_role, :ended_on, :main_duties, :subjects, :reason_for_leaving)
          .merge("started_on(3i)" => "1", "ended_on(3i)" => "1")
  end
end
