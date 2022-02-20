class Publishers::SchoolsController < Publishers::BaseController
  before_action :set_redirect_path, only: %i[edit update]
  before_action :set_organisation, only: %i[edit update]

  def show
    @organisation = current_publisher.organisations.find(params[:id])
  end

  def edit
    @organisation_form = Publishers::OrganisationForm.new(
      { description: @organisation.description, website: @organisation.website },
    )
  end

  def update
    @organisation_form = Publishers::OrganisationForm.new(organisation_params)

    if @organisation_form.valid?
      @organisation.update(organisation_params)
      redirect_to @redirect_path, success: t(".success_html", organisation: @organisation.name)
    else
      render :edit
    end
  end

  private

  def set_organisation
    @organisation = if current_organisation.school? ||
                       (current_organisation.school_group? && current_organisation.id == params[:id])
                      current_organisation
                    else
                      current_organisation.schools.find(params[:id])
                    end
  end

  def set_redirect_path
    @redirect_path = current_organisation.school? ? organisation_path : publishers_schools_path
  end

  def organisation_params
    params.require(:publishers_organisation_form).permit(:description, :website)
  end
end
