class Jobseekers::SearchResults::JobAlertsLinkComponent < ViewComponent::Base
  def initialize(vacancies_search:, count:)
    @vacancies_search = vacancies_search
    @count = count
  end

  def render?
    @vacancies_search.any? && !ReadOnlyFeature.enabled? && @count.positive?
  end
end
