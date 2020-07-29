class HiringStaff::SchoolOverviewComponent < ViewComponent::Base
  include OrganisationHelper

  def initialize(organisation:)
    @organisation = organisation
  end

  def render?
    @organisation.is_a?(School)
  end
end
