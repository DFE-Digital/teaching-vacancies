class Publishers::Organisations::PhotoController < Publishers::OrganisationsController
  before_action :organisation

  def edit
    @photo_form = Publishers::Organisation::PhotoForm.new(photo: @organisation.photo)
  end

  def update
    @photo_form = Publishers::Organisation::PhotoForm.new(photo_form_params)

    if @photo_form.valid?
      @organisation.photo.attach(@photo_form.photo)

      redirect_to publishers_organisation_path(@organisation), success: t("publishers.organisations.update_success", organisation_type: @organisation.school? ? "School" : "Organisation")
    else
      render :edit
    end
  end

  def destroy
    @organisation.photo.purge_later

    redirect_to publishers_organisation_path(@organisation), success: t("publishers.organisations.photo.destroy_success", organisation_type: @organisation.school? ? "School" : "Organisation")
  end

  def confirm_destroy; end

  private

  def photo_form_params
    (params[:publishers_organisation_photo_form] || params)&.permit(:photo)
  end
end
