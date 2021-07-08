class Jobseekers::SearchResults::HeadingComponent < ViewComponent::Base
  def initialize(vacancies_search:)
    @vacancies_search = vacancies_search
    @keyword = @vacancies_search.keyword
    @location = @vacancies_search.location_search.location
    @polygon_boundaries = @vacancies_search.location_search.polygon_boundaries
    @radius = @vacancies_search.search_criteria[:radius]
    @total_count = @vacancies_search.total_count
  end

  def heading
    if @keyword.present? && @polygon_boundaries.present?
      I18n.t("jobs.search_result_heading.keyword_location_polygon_html",
             jobs_count: number_with_delimiter(@total_count), location: @location, keyword: @keyword, count: @total_count, radius: @radius, units: I18n.t("jobs.search_result_heading.unit_of_length").pluralize(@radius.to_i))
    elsif @keyword.present? && @location.present?
      I18n.t("jobs.search_result_heading.keyword_location_html",
             jobs_count: number_with_delimiter(@total_count), location: @location, keyword: @keyword, count: @total_count, radius: @radius, units: I18n.t("jobs.search_result_heading.unit_of_length").pluralize(@radius.to_i))
    elsif @keyword.present?
      I18n.t("jobs.search_result_heading.keyword_html",
             jobs_count: number_with_delimiter(@total_count), keyword: @keyword, count: @total_count)
    elsif @polygon_boundaries.present?
      I18n.t("jobs.search_result_heading.location_polygon_html",
             jobs_count: number_with_delimiter(@total_count), location: @location, count: @total_count, radius: @radius, units: I18n.t("jobs.search_result_heading.unit_of_length").pluralize(@radius.to_i))
    elsif @location.present?
      I18n.t("jobs.search_result_heading.location_html",
             jobs_count: number_with_delimiter(@total_count), location: @location, count: @total_count, radius: @radius, units: I18n.t("jobs.search_result_heading.unit_of_length").pluralize(@radius.to_i))
    else
      I18n.t("jobs.search_result_heading.without_search_html",
             jobs_count: number_with_delimiter(@total_count), count: @total_count)
    end
  end
end
