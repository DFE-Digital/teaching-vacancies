class VacancySummaryComponent < ViewComponent::Base
  include OrganisationHelper
  include DatesHelper
  include VacanciesHelper

  def initialize(vacancy:)
    @vacancy = vacancy
  end
end
