class Search::AlertVacancySearch < Search::VacancySearch
  MAXIMUM_SUBSCRIPTION_RESULTS = 500

  def keyword
    # Generate a suitable keyword if one has not been set as part of the alert
    # TODO: This should probably be the responsibility of the subscription, not the search
    @keyword ||= [search_criteria[:subject], search_criteria[:job_title]].reject(&:blank?).join(" ")
  end

  private

  def algolia_params
    super.except(:page).merge(
      per_page: MAXIMUM_SUBSCRIPTION_RESULTS,
      typo_tolerance: false,
    )
  end
end
