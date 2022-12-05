class Publishers::OrganisationsController < Publishers::BaseController
  def show
    organisation
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
