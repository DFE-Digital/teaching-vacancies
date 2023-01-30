class Jobseekers::Profiles::AboutYouController < Jobseekers::ProfilesController
  def edit
    @profile = JobseekerProfile.find_by(jobseeker_id: current_jobseeker.id)
    @form = Jobseekers::Profile::AboutYouForm.new(about_you: @profile.about_you)
  end

  def update
    @form = Jobseekers::Profile::AboutYouForm.new(form_params)
    if @form.valid?
      @profile = JobseekerProfile.find_by(jobseeker_id: current_jobseeker.id)
      @profile.update(about_you: form_params[:about_you])
      redirect_to jobseekers_profile_about_you_path
    else
      render :edit
    end
  end

  def form_class
    "jobseekers/profile/about_you_form".camelize.constantize
  end

  def form_params
    params.require(:jobseekers_profile_about_you_form).permit(form_class.fields)
  end
end
