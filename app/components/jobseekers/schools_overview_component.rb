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
    @vacancy.schools.each { |school|
      return true if school.geolocation
    }
    false
  end
end
