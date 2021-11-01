class Jobseekers::SearchResults::HeadingComponent < ViewComponent::Base
  def initialize(vacancies_search:, landing_page:)
    @vacancies_search = vacancies_search
    @landing_page = landing_page
    @keyword = @vacancies_search.keyword
    @location = @vacancies_search.location_search.location
    @radius = @vacancies_search.location_search.radius
    @total_count = @vacancies_search.total_count
    @readable_count = number_with_delimiter(@total_count)
  end

  def heading
    if @landing_page.present? && Vacancy.job_roles.key?(@landing_page.underscore)
      return t("jobs.search_result_heading.landing_page_html", jobs_count: @readable_count, landing_page: job_role(@landing_page), count: @total_count)
    end

    if @keyword.blank? && @location.blank?
      return t("jobs.search_result_heading.without_search_html", jobs_count: @readable_count, count: @total_count)
    end

    [count_phrase, keyword_phrase, radius_phrase, location_phrase].compact.join(" ")
  end

  private

  def count_phrase
    t("jobs.search_result_heading.count_html", jobs_count: @readable_count, count: @total_count)
  end

  def keyword_phrase
    if @keyword.present?
      t("jobs.search_result_heading.keyword_html", keyword: @keyword, count: @total_count)
    else
      t("jobs.search_result_heading.no_keyword")
    end
  end

  def location_phrase
    return unless @location.present?

    t("jobs.search_result_heading.location_html", location: @location)
  end

  def radius_phrase
    return unless @location.present?

    # A radius of 0 is only possible for polygon searches.
    t("jobs.search_result_heading.radius_html", count: @radius, units: units)
  end

  def units
    t("jobs.search_result_heading.unit_of_length").pluralize(@radius.to_i)
  end

  def job_role(role)
    return role.sub("-", " ") unless role == "sendco"

    t("helpers.label.publishers_job_listing_job_details_form.job_roles_options.#{role}")
  end
end
