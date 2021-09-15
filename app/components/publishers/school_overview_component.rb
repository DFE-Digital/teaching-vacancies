class Publishers::SchoolOverviewComponent < ViewComponent::Base
  include OrganisationsHelper

  delegate :open_in_new_tab_link_to, to: :helpers

  def initialize(organisation:)
    @organisation = organisation
  end

  def render?
    @organisation.school?
  end

  def link_to_organisation
    if organisation_url(@organisation)
      open_in_new_tab_link_to(organisation_url(@organisation), organisation_url(@organisation), class: "wordwrap")
    else
      t("jobs.not_defined")
    end
  end
end
