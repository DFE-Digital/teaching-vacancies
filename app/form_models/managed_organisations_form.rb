class ManagedOrganisationsForm
  include ActiveModel::Model
  include OrganisationHelper

  attr_accessor :managed_organisations, :managed_school_ids

  attr_reader :sort_column

  validate :at_least_one_option_selected

  def initialize(params = {})
    @managed_organisations = params[:managed_organisations]
    @managed_school_ids = params[:managed_school_ids]
    @sort_column = params[:sort_column]
  end

private

  def at_least_one_option_selected
    return if managed_organisations.present? || managed_school_ids.any?

    errors.add(:managed_organisations, I18n.t("publishers_publisher_preference_errors.managed_organisations.blank"))
  end
end
