class Publishers::Organisations::LogoController < Publishers::OrganisationsController
  def edit
    organisation
    @logo_form = Publishers::Organisation::LogoForm.new(logo: organisation.logo)
  end

  def update
    @logo_form = Publishers::Organisation::LogoForm.new(logo_form_params)

    if @logo_form.valid?
      organisation.logo.attach(@logo_form.logo)

      redirect_to publishers_organisation_path(organisation), success: t("publishers.organisations.update_success", organisation_type: organisation.school? ? "School" : "Organisation")
    else
      organisation

      render :edit
    end
  end

  private

  def logo_form_params
    params.require(:publishers_organisation_logo_form).permit(:logo)
  end
end
