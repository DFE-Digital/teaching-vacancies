class Jobseekers::SearchResults::HeadingComponent < ViewComponent::Base
  def initialize(vacancies_search:)
    @vacancies_search = vacancies_search
    @keyword = @vacancies_search.keyword
    @location = @vacancies_search.location_search.location
    @total_count = @vacancies_search.vacancies.raw_answer['nbHits']
  end

  def heading
    if @keyword.present? && @location.present?
      I18n.t('jobs.search_result_heading.keyword_location_html',
        jobs_count: number_with_delimiter(@total_count), location: @location, keyword: @keyword, count: @total_count)
    elsif @keyword.present?
      I18n.t('jobs.search_result_heading.keyword_html',
        jobs_count: number_with_delimiter(@total_count), keyword: @keyword, count: @total_count)
    elsif @location.present?
      I18n.t('jobs.search_result_heading.location_html',
        jobs_count: number_with_delimiter(@total_count), location: @location, count: @total_count)
    else
      I18n.t('jobs.search_result_heading.without_search_html',
        jobs_count: number_with_delimiter(@total_count), count: @total_count)
    end
  end
end
