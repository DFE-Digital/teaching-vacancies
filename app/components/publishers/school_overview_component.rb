class Publishers::SchoolOverviewComponent < ViewComponent::Base
  include OrganisationsHelper

  delegate :open_in_new_tab_link_to, to: :helpers

  def initialize(organisation:)
    @organisation = organisation
  end

  def render?
    @organisation.school?
  end

  def link
    if url(@organisation)
      open_in_new_tab_link_to(url(@organisation), url(@organisation), class: "wordwrap")
    else
      t("jobs.not_defined")
    end
  end
end
