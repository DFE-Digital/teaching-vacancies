class Publishers::SchoolsController < Publishers::BaseController
  def index
    @organisation = current_organisation
  end

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
      redirect_to redirect_path, success: t(".success_html", organisation: organisation.name)
    else
      render :edit
    end
  end

  private

  def organisation
    @organisation ||= current_organisation.id == params[:id] ? current_organisation : current_organisation.schools.find(params[:id])
  end

  def redirect_path
    current_organisation.school? ? publishers_school_path(current_organisation.id) : publishers_schools_path
  end

  def organisation_params
    params.require(:publishers_organisation_form).permit(:description, :url_override)
  end
end
