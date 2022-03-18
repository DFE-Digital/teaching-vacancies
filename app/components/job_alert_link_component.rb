class JobAlertLinkComponent < ViewComponent::Base
  def initialize(vacancies_search:, count:)
    @vacancies_search = vacancies_search
    @count = count
  end

  def render?
    @vacancies_search.active_criteria? && @count.positive?
  end
end
