class Jobseekers::Profile::SelectOrganisationForm < BaseForm
  include ActiveRecord::AttributeAssignment

  attr_accessor :organisation_name

  validates :organisation, presence: true

  def organisation
    return if organisation_name.blank?

    @organisation ||= Organisation.visible_to_jobseekers.find_by(name: organisation_name)
  end
end
