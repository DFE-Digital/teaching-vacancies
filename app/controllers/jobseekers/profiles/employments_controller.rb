class Jobseekers::Profiles::EmploymentsController < Jobseekers::ProfilesController
  def new
    @form = Jobseekers::Profile::EmploymentForm.new
  end

  def edit
    @form = Jobseekers::Profile::EmploymentForm.new(employment.slice(*employment_attrs))
  end

  def create
    @form = Jobseekers::Profile::EmploymentForm.new(employment_form_params)

    if @form.valid?
      profile.employments.create(employment_form_params)
      redirect_to review_jobseekers_profile_work_history_index_path
    else
      render :new
    end
  end

  def update
    @form = Jobseekers::Profile::EmploymentForm.new(employment_form_params)

    if @form.valid?
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

  def employment
    profile.employments.find(params[:id])
  end

  def employment_form_params
    params.require(:jobseekers_profile_employment_form)
          .permit(:organisation, :job_title, :started_on, :ended_on, :main_duties, :subjects, :reason_for_leaving, current_role: [])
          .merge("started_on(3i)" => "1", "ended_on(3i)" => "1")
  end

  def employment_attrs
    %i[organisation job_title started_on is_current_role ended_on main_duties subjects reason_for_leaving].freeze
  end
end
