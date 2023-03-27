class Jobseekers::Profile::SelectOrganisationForm < BaseForm
  include ActiveRecord::AttributeAssignment

  attr_accessor :organisation_name, :organisation_id

  validates :organisation, presence: true

  def organisation
    return if organisation_name.blank? && organisation_id.blank?

    @organisation ||= orgs.find_by(id: organisation_id) || orgs.find_by(name: organisation_name)
  end

  private

  def orgs
    Organisation.visible_to_jobseekers
  end
end
