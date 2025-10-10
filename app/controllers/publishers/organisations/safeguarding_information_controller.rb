class Publishers::Organisations::SafeguardingInformationController < Publishers::OrganisationsController
  def edit
    organisation
    @safeguarding_information_form = Publishers::Organisation::SafeguardingInformationForm.new(safeguarding_information: organisation.safeguarding_information)
  end

  def update
    @safeguarding_information_form = Publishers::Organisation::SafeguardingInformationForm.new(safeguarding_information_form_params)

    if @safeguarding_information_form.valid?
      organisation.update(safeguarding_information: @safeguarding_information_form.safeguarding_information)

      if params[:publishers_organisation_safeguarding_information_form][:vacancy_id]
        redirect_to organisation_job_build_path(params[:publishers_organisation_safeguarding_information_form][:vacancy_id], :about_the_role)
      else
        redirect_to publishers_organisation_path(organisation), success: t("publishers.organisations.update_success", organisation_type: organisation.school? ? "School" : "Organisation")
      end
    else
      organisation

      render :edit
    end
  end

  private

  def safeguarding_information_form_params
    params.expect(publishers_organisation_safeguarding_information_form: [:safeguarding_information])
  end
end
