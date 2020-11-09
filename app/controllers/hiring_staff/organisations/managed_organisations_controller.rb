class HiringStaff::Organisations::ManagedOrganisationsController < HiringStaff::BaseController
  include OrganisationHelper

  before_action :verify_school_group
  before_action :set_organisation_options

  def show
    @managed_organisations_form = ManagedOrganisationsForm.new(vacancy_filter.to_h)
  end

  def update
    @managed_organisations_form = ManagedOrganisationsForm.new(managed_organisations_params)

    if params[:commit] == I18n.t("buttons.apply_filters")
      vacancy_filter.update(managed_organisations_params)
      redirect_to jobs_with_type_organisation_path(params[:managed_organisations_form][:jobs_type])
    elsif @managed_organisations_form.valid? || params[:commit] == I18n.t("buttons.skip_this_step")
      vacancy_filter.update(managed_organisations_params)
      redirect_to organisation_path
    else
      render :show
    end
  end

private

  def managed_organisations_params
    strip_empty_checkboxes(%i[managed_organisations managed_school_ids], :managed_organisations_form)
    params.require(:managed_organisations_form).permit(managed_organisations: [], managed_school_ids: [])
  end

  def vacancy_filter
    @vacancy_filter ||= HiringStaff::VacancyFilter.new(current_user, current_school_group)
  end

  def set_organisation_options
    @organisation_options = current_organisation.schools.order(:name).map do |school|
      OpenStruct.new({ id: school.id, name: school.name, address: full_address(school) })
    end
    unless current_organisation.group_type == "local_authority"
      @organisation_options.unshift(
        OpenStruct.new({ id: current_organisation.id,
                         name: I18n.t("hiring_staff.organisations.managed_organisations.show.options.school_group"),
                         address: full_address(current_organisation) }),
      )
    end
  end
end
