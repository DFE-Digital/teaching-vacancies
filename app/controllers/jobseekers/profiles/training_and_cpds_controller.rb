class Jobseekers::Profiles::TrainingAndCpdsController < Jobseekers::ProfilesController
  helper_method :jobseeker_profile, :form

  def edit
    binding.pry
  end

  def new
  end

  def create
    if form.valid?
      profile.training_and_cpds.create(training_and_cpd_form_params)
      redirect_to review_jobseekers_profile_training_and_cpds_path
    else
      render :new
    end
  end

  def update
    if form.valid?
      training_and_cpds.update(training_and_cpd_form_params)
      redirect_to review_jobseekers_profile_training_and_cpds_path
    else
      render :edit
    end
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
    @training_and_cpd ||= profile.training_and_cpds.find(params[:id] || params[:training_and_cpd_id])
  end
end