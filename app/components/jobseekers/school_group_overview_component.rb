class Jobseekers::SchoolGroupOverviewComponent < ViewComponent::Base
  include OrganisationHelper
  include VacanciesHelper

  def initialize(vacancy:)
    @vacancy = vacancy
  end
end
