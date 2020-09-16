class Jobseekers::SchoolOverviewComponent < ViewComponent::Base
  include OrganisationHelper
  include VacanciesHelper

  def initialize(vacancy:)
    @vacancy = vacancy
    @school = vacancy.parent_organisation
  end

  def render?
    @vacancy.at_one_school?
  end

  def school_map_data
    school_data = { name: @school.name,
                    lat: @school.geolocation.x,
                    lng: @school.geolocation.y }
    school_data.to_json
  end
end
