class Publishers::OrganisationsController < Publishers::BaseController
  def show
    organisation
  end

  def preview
    @organisation = Organisation.friendly.find(params[:organisation_id])
  end

  def profile_incomplete
    organisation
  end

  private

  # :nocov:
  def organisation
    id = params[:id] || params[:organisation_id]
    @organisation ||= if id&.in?([current_organisation.friendly_id, current_organisation.id])
                        current_organisation
                      elsif current_organisation.is_a?(SchoolGroup)
                        current_organisation.schools.friendly.find(id)
                      end
    raise ActiveRecord::RecordNotFound unless @organisation

    @organisation
  end
  # :nocov:

  def organisation_params
    params.require(:publishers_organisation_form).permit(:description, :email, :safeguarding_information, :url_override)
  end

  def back_link_destination
    if params[:vacancy_id]
      organisation_job_build_path(params[:vacancy_id], :about_the_role)
    else
      publishers_organisation_path(@organisation)
    end
  end
  helper_method :back_link_destination
end
