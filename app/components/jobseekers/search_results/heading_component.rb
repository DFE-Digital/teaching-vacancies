class Jobseekers::SearchResults::HeadingComponent < ViewComponent::Base
  def initialize(vacancies_search:, landing_page:)
    @vacancies_search = vacancies_search
    @landing_page = landing_page
    @keyword = @vacancies_search.keyword
    @location = @vacancies_search.location_search.location
    @polygon_boundaries = @vacancies_search.location_search.polygon_boundaries
    @radius = @vacancies_search.search_criteria[:radius]
    @total_count = @vacancies_search.total_count
    @readable_count = number_with_delimiter(@total_count)
  end

  def heading
    if @landing_page.present? && Vacancy.job_roles.keys?(@landing_page.underscore)
      t("jobs.search_result_heading.landing_page_html", jobs_count: @readable_count, landing_page: @landing_page.titleize.downcase, count: @total_count)
    elsif @keyword.present? && @polygon_boundaries.present?
      t("jobs.search_result_heading.keyword_location_polygon_html", jobs_count: @readable_count, location: @location, keyword: @keyword, count: @total_count, radius: @radius, units: units)
    elsif @keyword.present? && @location.present?
      t("jobs.search_result_heading.keyword_location_html", jobs_count: @readable_count, location: @location, keyword: @keyword, count: @total_count, radius: @radius, units: units)
    elsif @keyword.present?
      t("jobs.search_result_heading.keyword_html", jobs_count: @readable_count, keyword: @keyword, count: @total_count)
    elsif @polygon_boundaries.present?
      t("jobs.search_result_heading.location_polygon_html", jobs_count: @readable_count, location: @location, count: @total_count, radius: @radius, units: units)
    elsif @location.present?
      t("jobs.search_result_heading.location_html", jobs_count: @readable_count, location: @location, count: @total_count, radius: @radius, units: units)
    else
      t("jobs.search_result_heading.without_search_html", jobs_count: @readable_count, count: @total_count)
    end
  end

  private

  def units
    t("jobs.search_result_heading.unit_of_length").pluralize(@radius.to_i)
  end
end
