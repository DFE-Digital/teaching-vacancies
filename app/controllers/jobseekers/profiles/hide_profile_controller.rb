class Jobseekers::Profiles::HideProfileController < Jobseekers::ProfilesController
  def show
    @form = Jobseekers::Profile::HideProfileForm.new(hide_profile: profile.hide_profile)
  end

  def confirm_hide
    form_params = params
      .require(:jobseekers_profile_hide_profile_form)
      .permit(:hide_profile)

    if (@form = Jobseekers::Profile::HideProfileForm.new(form_params)).valid?
      profile.update(hide_profile: @form.hide_profile)

      if profile.hide_profile?
        redirect_to add_jobseekers_profile_hide_profile_path
      else
        redirect_to review_jobseekers_profile_hide_profile_path
      end
    else
      render :show
    end
  end

  def add
    @form = Jobseekers::Profile::SelectOrganisationForm.new
  end

  def add_school
    form_params = params
      .require(:jobseekers_profile_select_organisation_form)
      .permit(:organisation_name)

    if (@form = Jobseekers::Profile::SelectOrganisationForm.new(form_params)).valid?
      profile.excluded_organisations << @form.organisation unless profile.excluded_organisations.include?(@form.organisation)
      redirect_to schools_jobseekers_profile_hide_profile_path
    else
      redirect_to cannot_find_school_jobseekers_profile_hide_profile_path
    end
  end

  def cannot_find_school; end

  def add_another
    if params.dig(:jobseekers_profile_add_another_form, :add_another) == "true"
      redirect_to add_jobseekers_profile_hide_profile_path
    else
      redirect_to review_jobseekers_profile_hide_profile_path
    end
  end

  def delete
    @exclusion = profile.organisation_exclusions.find(params[:exclusion_id])
  end

  def destroy
    exclusion = profile.organisation_exclusions.find(params[:exclusion_id])
    exclusion.destroy
    redirect_to schools_jobseekers_profile_hide_profile_path
  end

  def schools
    @form = Jobseekers::Profile::AddAnotherForm.new
  end

  def review; end
end
