class Jobseekers::Profiles::AboutYouController < Jobseekers::ProfilesController
  def edit; end

  def update
    if form.valid?
      profile.update(about_you: form.about_you)
      redirect_to jobseekers_profile_about_you_path
    else
      render :edit
    end
  end

  private

  helper_method :form

  def form
    @form ||= Jobseekers::Profile::AboutYouForm.new(form_attributes)
  end

  def form_attributes
    case action_name
    when "edit"
      profile.slice(:about_you)
    when "update"
      form_params
    end
  end

  def form_class
    "jobseekers/profile/about_you_form".camelize.constantize
  end

  def form_params
    params.require(:jobseekers_profile_about_you_form).permit(form_class.fields)
  end
end
