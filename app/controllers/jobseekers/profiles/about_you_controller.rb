class Jobseekers::Profiles::AboutYouController < Jobseekers::ProfilesController
  def edit
    @form = form_class.new(@profile.slice(:about_you))
  end

  # :nocov:
  def update
    @form = form_class.new(form_params)
    if @form.valid?
      @profile.update(about_you: @form.about_you)
      redirect_to jobseekers_profile_about_you_path
    else
      render :edit
    end
  end
  # :nocov:

  private

  def form_class
    Jobseekers::Profile::AboutYouForm
  end

  # the new version doesn't allow empty submissions
  # rubocop:disable Rails/StrongParametersExpect
  def form_params
    params.permit(jobseekers_profile_about_you_form: form_class.fields).require(:jobseekers_profile_about_you_form)
  end
  # rubocop:enable Rails/StrongParametersExpect
end
