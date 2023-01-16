class Publishers::Organisations::DescriptionController < Publishers::OrganisationsController
  def edit
    organisation
    @description_form = Publishers::Organisation::DescriptionForm.new(description: organisation.description)
  end

  def update
    @description_form = Publishers::Organisation::DescriptionForm.new(description_form_params)

    if @description_form.valid?
      organisation.update(description: params[:publishers_organisation_description_form][:description])

      if params[:publishers_organisation_description_form][:vacancy_id]
        redirect_to organisation_job_build_path(params[:publishers_organisation_description_form][:vacancy_id], :about_the_role)
      else
        redirect_to publishers_organisation_path(organisation), success: t("publishers.organisations.update_success", organisation_type: organisation.school? ? "School" : "Organisation")
      end
    else
      organisation

      render :edit
    end
  end

  private

  def description_form_params
    params.require(:publishers_organisation_description_form).permit(:description)
  end
end
