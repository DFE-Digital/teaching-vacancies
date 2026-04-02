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

  # def form_class
  #   Jobseekers::Profile::AboutYouForm
  # end

  # the new version doesn't allow empty submissions
  # rubocop:disable Rails/StrongParametersExpect
  def form_params
    params.permit(jobseeker_profile: :about_you).require(:jobseeker_profile)
  end
  # rubocop:enable Rails/StrongParametersExpect
end
