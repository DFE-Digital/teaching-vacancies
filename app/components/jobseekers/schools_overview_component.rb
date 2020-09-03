class Jobseekers::SchoolsOverviewComponent < ViewComponent::Base
  include OrganisationHelper
  include VacanciesHelper

  def initialize(vacancy:)
    @vacancy = vacancy
  end

  def render?
    @vacancy.at_multiple_schools?
  end
end
