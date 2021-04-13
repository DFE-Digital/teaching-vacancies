class Publishers::SchoolOverviewComponent < ViewComponent::Base
  include OrganisationHelper

  def initialize(organisation:)
    @organisation = organisation
  end

  def render?
    @organisation.school?
  end
end
