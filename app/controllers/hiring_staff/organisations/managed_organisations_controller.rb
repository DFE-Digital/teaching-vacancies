class HiringStaff::Organisations::ManagedOrganisationsController < HiringStaff::BaseController
  include OrganisationHelper

  before_action :verify_school_group
  before_action :set_school_options

  def show
    @managed_organisations_form = ManagedOrganisationsForm.new(vacancy_filter.to_h)
  end

  def update
    @managed_organisations_form = ManagedOrganisationsForm.new(managed_organisations_params)

    if params[:commit] == I18n.t('buttons.apply_filters')
      set_managed_organisations
      vacancy_filter.update(managed_organisations_params)
      redirect_to jobs_with_type_organisation_path(params[:managed_organisations_form][:jobs_type])
    elsif @managed_organisations_form.valid? || params[:commit] == I18n.t('buttons.skip_this_step')
      vacancy_filter.update(managed_organisations_params)
      redirect_to organisation_path
    else
      render :show
    end
  end

  private

  def managed_organisations_params
    strip_empty_checkboxes(:managed_organisations_form, [:managed_organisations, :managed_school_ids])
    params.require(:managed_organisations_form).permit(managed_organisations: [], managed_school_ids: [])
  end

  def vacancy_filter
    @vacancy_filter ||= HiringStaff::VacancyFilter.new(current_user, current_school_group)
  end

  def set_school_options
    @school_options = current_organisation.schools.order(:name).map do |school|
      OpenStruct.new({ id: school.id, name: school.name, address: full_address(school) })
    end
  end

  def set_managed_organisations
    params[:managed_organisations_form][:managed_organisations] ||= []
    params[:managed_organisations_form][:managed_organisations].push('school_group') if
      params[:managed_organisations_form][:managed_school_ids].include?('school_group')
  end
end
