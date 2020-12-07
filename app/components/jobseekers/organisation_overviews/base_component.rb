class Jobseekers::OrganisationOverviews::BaseComponent < ViewComponent::Base
  include OrganisationHelper
  include VacanciesHelper

  attr_accessor :organisation, :vacancy

  def initialize(vacancy:)
    @vacancy = vacancy
    @organisation = vacancy.parent_organisation
  end

  def organisation_map_data
    { name: organisation&.name, lat: organisation.geolocation&.x, lng: organisation.geolocation&.y }.to_json
  end
end
