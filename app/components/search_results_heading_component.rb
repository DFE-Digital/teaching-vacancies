class SearchResultsHeadingComponent < ViewComponent::Base
  def initialize(vacancies_search:, landing_page:)
    @vacancies_search = vacancies_search
    @landing_page = landing_page
    @keyword = @vacancies_search.keyword
    @location = @vacancies_search.location_search.location
    @transportation_type = @vacancies_search.transportation_type
    @travel_time = @vacancies_search.travel_time
    @total_count = @vacancies_search.total_count
    @readable_count = number_with_delimiter(@total_count)
    @organisation_slug = @vacancies_search.organisation_slug
  end

  def heading
    return @landing_page.heading if @landing_page

    if @keyword.blank? && @location.blank? && @organisation_slug.blank?
      return t("jobs.search_result_heading.without_search_html", jobs_count: @readable_count, count: @total_count)
    end

    [count_phrase, keyword_phrase, commute_phrase, location_phrase, organisation_phrase].compact.join(" ")
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

  def commute_phrase
    return unless @location.present?
    return "in" unless @transportation_type.present? && @travel_time.present?

    t("jobs.search_result_heading.commute_html", minutes: @travel_time, transportation_type: @transportation_type.humanize.downcase)
  end

  def organisation_phrase
    return unless @organisation_slug.present?

    t("jobs.search_result_heading.organisation_html", organisation: @vacancies_search.organisation.name)
  end

  def job_role(role)
    role.tr("-", " ").humanize(capitalize: false)
  end
end
