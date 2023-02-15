class Publishers::Organisations::LogoController < Publishers::OrganisationsController
  before_action :organisation

  def edit
    @logo_form = Publishers::Organisation::LogoForm.new(logo: @organisation.logo)
  end

  def update
    @logo_form = Publishers::Organisation::LogoForm.new(logo_form_params)

    if @logo_form.valid?
      # 100x100 size chosen to give us some room if we later decide to increase the size we display logos at
      normalised_logo = ImageManipulator.new(image_file_path: @logo_form.logo.tempfile.path).alter_dimensions_and_preserve_aspect_ratio("100", "100")

      @organisation.logo.attach(io: StringIO.open(normalised_logo.to_blob), filename: @logo_form.logo.original_filename)

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
