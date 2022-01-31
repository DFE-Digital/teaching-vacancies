class Jobseekers::OrganisationOverviews::BaseComponent < ViewComponent::Base
  include OrganisationsHelper
  include VacanciesHelper

  delegate :open_in_new_tab_link_to, :tracked_open_in_new_tab_link_to, to: :helpers

  attr_accessor :organisation, :vacancy

  def initialize(vacancy:)
    @vacancy = vacancy
    @organisation = vacancy.parent_organisation
  end

  def map_links
    @map_links ||=
      vacancy.organisations.map do |organisation|
        { text: "#{organisation.name}, #{full_address(organisation)}", url: organisation_url(organisation), id: organisation.id }
      end
  end
end
