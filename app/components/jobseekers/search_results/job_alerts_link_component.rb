class Jobseekers::SearchResults::JobAlertsLinkComponent < ViewComponent::Base
  def initialize(vacancies_search:)
    @vacancies_search = vacancies_search
  end

  def render?
    @vacancies_search.any? && EmailAlertsFeature.enabled? && !ReadOnlyFeature.enabled?
  end
end
