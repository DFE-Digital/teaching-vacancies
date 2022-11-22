class Publishers::OrganisationsController < Publishers::BaseController
  def show
    organisation
  end

  def edit
    @organisation_form = Publishers::OrganisationForm.new(
      description: organisation.description, url_override: organisation.url_override,
    )
  end

  def update
    @organisation_form = Publishers::OrganisationForm.new(organisation_params)

    if organisation && @organisation_form.valid?
      organisation.update(organisation_params)
      redirect_to publishers_organisation_path(organisation), success: t(".success", organisation_type: organisation.school? ? "School" : "Organisation")
    else
      render :edit
    end
  end

  def preview
    @organisation = Organisation.friendly.find(params[:organisation_id])
  end

  private

  def organisation
    @organisation ||= if current_organisation.friendly_id == (params[:id] || params[:organisation_id])
                        current_organisation
                      else
                        current_organisation.schools.friendly.find(params[:id] || params[:organisation_id])
                      end
  end

  def organisation_params
    params.require(:publishers_organisation_form).permit(:description, :url_override)
  end
end
