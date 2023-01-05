class Publishers::Organisations::PhotoController < Publishers::OrganisationsController
  def edit
    organisation
    @photo_form = Publishers::Organisation::PhotoForm.new(photo: organisation.photo)
  end

  def update
    @photo_form = Publishers::Organisation::PhotoForm.new(photo_form_params)

    if @photo_form.valid?
      organisation.photo.attach(@photo_form.photo)

      redirect_to publishers_organisation_path(organisation), success: t("publishers.organisations.update_success", organisation_type: organisation.school? ? "School" : "Organisation")
    else
      organisation

      render :edit
    end
  end

  private

  def photo_form_params
    (params[:publishers_organisation_photo_form] || params)&.permit(:photo)
  end
end
