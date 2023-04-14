class Jobseekers::Profiles::HideProfileController < Jobseekers::ProfilesController
  def show
    @form = Jobseekers::Profile::HideProfileForm.new(requested_hidden_profile: profile.requested_hidden_profile)
  end

  def confirm_hide
    form_params = params
      .require(:jobseekers_profile_hide_profile_form)
      .permit(:requested_hidden_profile)

    if (@form = Jobseekers::Profile::HideProfileForm.new(form_params)).valid?
      profile.update!(requested_hidden_profile: @form.requested_hidden_profile)

      if profile.requested_hidden_profile?
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

    form = Jobseekers::Profile::SelectOrganisationForm.new(form_params)

    if form.organisation.respond_to?(:part_of_a_trust?) && form.organisation.part_of_a_trust?
      redirect_to choose_school_or_trust_jobseekers_profile_hide_profile_path(school_id: form.organisation.id)
    else
      hide_school(form)
    end
  end

  def choose_school_or_trust
    @form = Jobseekers::Profile::ChooseSchoolOrTrustForm.new
    @school = School.visible_to_jobseekers.find(params[:school_id])
  end

  def add_school_or_trust
    form_params = params
      .require(:jobseekers_profile_choose_school_or_trust_form)
      .permit(:organisation_id)

    form = Jobseekers::Profile::SelectOrganisationForm.new(form_params)

    hide_school(form)
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

  private

  def hide_school(form)
    if form.valid?
      if profile.excluded_organisations.include?(form.organisation)
        flash[:important] = t("jobseekers.profiles.hide_profile.schools.already_hidden", name: form.organisation.name)
      else
        profile.excluded_organisations << form.organisation
      end

      redirect_to schools_jobseekers_profile_hide_profile_path
    else
      redirect_to cannot_find_school_jobseekers_profile_hide_profile_path
    end
  end
end
