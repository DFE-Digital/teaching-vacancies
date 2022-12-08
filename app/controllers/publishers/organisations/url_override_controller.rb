class Publishers::Organisations::UrlOverrideController < Publishers::OrganisationsController
  def edit
    organisation
    @url_override_form = Publishers::Organisation::UrlOverrideForm.new(url_override: organisation.url_override)
  end

  def update
    @url_override_form = Publishers::Organisation::UrlOverrideForm.new(url_override_form_params)

    if @url_override_form.valid?
      organisation.update!(url_override: @url_override_form.url_override)

      redirect_to publishers_organisation_path(organisation), success: t("publishers.organisations.update_success", organisation_type: organisation.school? ? "School" : "Organisation")
    else
      organisation

      render :edit
    end
  end

  private

  def url_override_form_params
    params.require(:publishers_organisation_url_override_form).permit(:url_override)
  end
end
