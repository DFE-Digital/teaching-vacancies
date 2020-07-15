class ManagedOrganisationsForm
  include ActiveModel::Model

  attr_accessor :current_preference, :current_organisation, :current_user,
                :managed_organisations, :managed_school_urns, :school_options

  validate :at_least_one_option_selected

  def initialize(current_user, current_organisation, params = {})
    @current_user = current_user
    @current_organisation = current_organisation
    @current_preference = UserPreference.find_or_initialize_by(
      user_id: current_user.id, school_group_id: current_organisation.id
    )
    @managed_organisations = params[:managed_organisations] || current_preference.managed_organisations
    @managed_school_urns = params[:managed_school_urns] || current_preference.managed_school_urns
    @school_options = current_organisation.schools.present? ?
      current_organisation.schools.sort_by { |school| school.name } : []
  end

  def save
    if managed_organisations.include?('all')
      @managed_organisations = 'all'
      @managed_school_urns = []
    elsif managed_organisations.include?('school_group')
      @managed_organisations = 'school_group'
    end

    current_preference.update(managed_organisations: managed_organisations, managed_school_urns: managed_school_urns)
    current_preference.save
  end

  private

  def at_least_one_option_selected
    errors.add(:managed_organisations, I18n.t('hiring_staff_user_preference_errors.managed_organisations.blank')) if
      managed_organisations.blank? && managed_school_urns.blank?
  end
end
