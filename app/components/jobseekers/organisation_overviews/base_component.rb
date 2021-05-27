class Jobseekers::OrganisationOverviews::BaseComponent < ViewComponent::Base
  include OrganisationHelper
  include VacanciesHelper

  delegate :open_in_new_tab_link_to, to: :helpers

  attr_accessor :organisation, :vacancy

  def initialize(vacancy:)
    @vacancy = vacancy
    @organisation = vacancy.parent_organisation
  end

  def organisation_map_data
    { name: organisation&.name, lat: organisation.geolocation&.x, lng: organisation.geolocation&.y }.to_json
  end
end
