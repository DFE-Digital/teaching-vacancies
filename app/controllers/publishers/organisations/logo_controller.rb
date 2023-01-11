class Publishers::Organisations::LogoController < Publishers::OrganisationsController
  before_action :organisation

  def edit
    @logo_form = Publishers::Organisation::LogoForm.new(logo: @organisation.logo)
  end

  def update
    @logo_form = Publishers::Organisation::LogoForm.new(logo_form_params)

    if @logo_form.valid?
      @organisation.logo.attach(@logo_form.logo)

      redirect_to publishers_organisation_path(@organisation), success: t("publishers.organisations.update_success", organisation_type: @organisation.school? ? "School" : "Organisation")
    else
      render :edit
    end
  end

  def destroy
    @organisation.logo.purge_later

    redirect_to publishers_organisation_path(@organisation), success: t("publishers.organisations.logo.destroy_success", organisation_type: @organisation.school? ? "School" : "Organisation")
  end

  def confirm_destroy; end

  private

  def logo_form_params
    (params[:publishers_organisation_logo_form] || params)&.permit(:logo)
  end
end
