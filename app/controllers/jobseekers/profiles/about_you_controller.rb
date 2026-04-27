class Jobseekers::Profiles::AboutYouController < Jobseekers::ProfilesController
  def edit; end

  def update
    @profile.assign_attributes(about_you_richtext: form_params.fetch(:about_you))
    if @profile.save(context: :about_you)
      redirect_to jobseekers_profile_about_you_path
    else
      render :edit
    end
  end

  private

  def form_params
    params.expect(jobseeker_profile: :about_you)
  end
end
