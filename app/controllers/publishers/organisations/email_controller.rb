class Publishers::Organisations::EmailController < Publishers::OrganisationsController
  def edit
    organisation
    @email_form = Publishers::Organisation::EmailForm.new(email: organisation.email)
  end

  def update
    @email_form = Publishers::Organisation::EmailForm.new(email_form_params)

    if @email_form.valid?
      organisation.update(email: @email_form.email)

      redirect_to publishers_organisation_path(organisation), success: t("publishers.organisations.update_success", organisation_type: organisation.school? ? "School" : "Organisation")
    else
      organisation

      render :edit
    end
  end

  private

  def email_form_params
    params.require(:publishers_organisation_email_form).permit(:email)
  end
end
