class Jobseekers::VacancySummaryComponent < ViewComponent::Base
  include OrganisationsHelper
  include DatesHelper
  include VacanciesHelper

  def initialize(vacancy:)
    @vacancy = vacancy
  end
end
