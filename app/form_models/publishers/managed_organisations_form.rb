class Publishers::ManagedOrganisationsForm
  include ActiveModel::Model

  attr_accessor :managed_organisations, :managed_school_ids

  validate :at_least_one_option_selected

  private

  def at_least_one_option_selected
    return if managed_organisations.present? || managed_school_ids.any?

    errors.add(:managed_organisations, I18n.t("publishers_publisher_preference_errors.managed_organisations.blank"))
  end
end
