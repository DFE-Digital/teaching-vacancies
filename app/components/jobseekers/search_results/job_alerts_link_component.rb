class Jobseekers::SearchResults::JobAlertsLinkComponent < ViewComponent::Base
  def initialize(vacancies_search:, count:, origin:)
    @vacancies_search = vacancies_search
    @count = count
    @origin = origin
  end

  def render?
    @vacancies_search.any? && !ReadOnlyFeature.enabled? && @count.positive?
  end
end
