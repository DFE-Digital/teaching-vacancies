class Jobseekers::OrganisationOverviews::BaseComponent < ViewComponent::Base
  include OrganisationsHelper
  include VacanciesHelper

  delegate :open_in_new_tab_link_to, to: :helpers

  attr_accessor :organisation, :vacancy

  def initialize(vacancy:)
    @vacancy = vacancy
    @organisation = vacancy.parent_organisation
  end

  def organisation_map_data
    { name: organisation&.name, lat: organisation.geopoint&.lat, lng: organisation.geopoint&.lon }.to_json
  end
end
