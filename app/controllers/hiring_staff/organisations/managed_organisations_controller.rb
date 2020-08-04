class HiringStaff::Organisations::ManagedOrganisationsController < HiringStaff::BaseController
  include OrganisationHelper

  before_action :verify_school_group
  before_action :set_school_options

  def show
    @managed_organisations_form = ManagedOrganisationsForm.new(vacancy_filter.to_h)
  end

  def update
    @managed_organisations_form = ManagedOrganisationsForm.new(managed_organisations_params)

    if @managed_organisations_form.valid? || params[:commit] == 'Skip this step'
      vacancy_filter.update(managed_organisations_params)
      redirect_to organisation_path
    else
      render :show
    end
  end

  private

  def managed_organisations_params
    params.require(:managed_organisations_form).permit(managed_organisations: [], managed_school_urns: [])
  end

  def vacancy_filter
    @vacancy_filter ||= HiringStaff::VacancyFilter.new(current_user, current_school_group)
  end

  def set_school_options
    @school_options = current_organisation.schools.order(:name).map do |school|
      OpenStruct.new({ urn: school.urn, name: school.name, address: full_address(school) })
    end
  end
end
