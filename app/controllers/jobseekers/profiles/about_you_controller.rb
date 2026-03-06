class Jobseekers::Profiles::AboutYouController < Jobseekers::ProfilesController
  def edit; end

  # :nocov:
  def update
    @profile.assign_attributes(about_you_richtext: form_params.fetch(:about_you))
    if @profile.save(context: :about_you)
      redirect_to jobseekers_profile_about_you_path
    else
      render :edit
    end
  end
  # :nocov:

  private

  # the new version doesn't allow empty submissions
  # rubocop:disable Rails/StrongParametersExpect
  def form_params
    params.permit(jobseekers_profile_about_you_form: form_class.fields).require(:jobseekers_profile_about_you_form)
  end
  # rubocop:enable Rails/StrongParametersExpect
end
