class Jobseekers::SchoolsOverviewComponent < ViewComponent::Base
  include OrganisationHelper
  include VacanciesHelper

  def initialize(vacancy:)
    @vacancy = vacancy
  end

  def render?
    @vacancy.at_multiple_schools?
  end

  def any_school_has_a_geolocation?
    @vacancy.schools.each do |school|
      return true if school.geolocation
    end
    false
  end

  def schools_map_data
    schools = []
    schools_with_a_geolocation.each do |school|
      schools.push({ name: school.name,
                     name_link: link_to(school.name, school.url),
                     address: full_address(school),
                     school_type: organisation_type(organisation: school, with_age_range: false),
                     lat: school.geolocation.x,
                     lng: school.geolocation.y })
    end
    schools.to_json
  end

private

  def schools_with_a_geolocation
    @vacancy.schools.select(&:geolocation)
  end
end
