class VacancyFacets
  CACHE_DURATION = 24.hours

  def additional_job_roles
    cached(:additional_job_roles) { job_role_facet.select { |role| role.in?(Vacancy.additional_job_role_options) }.to_h }
  end

  def cities
    cached(:cities) { sort_and_limit(city_facet, number_of_results: 20) }
  end

  def counties
    cached(:counties) { sort_and_limit(county_facet, number_of_results: 20) }
  end

  def education_phases
    cached(:education_phases) { without_empty_results(education_phase_facet).to_h }
  end

  def job_roles
    cached(:job_roles) { sort_and_limit(job_role_facet.select { |role| role.in?(Vacancy.main_job_role_options) }) }
  end

  def subjects
    cached(:subjects) { sort_and_limit(subject_facet, number_of_results: 10) }
  end

  private

  def cached(facet_name, &block)
    Rails.cache.fetch([:vacancy_facets, facet_name], expires_in: CACHE_DURATION, &block)
  end

  def sort_and_limit(facet, number_of_results: facet.count)
    without_empty_results(facet)
      .sort_by { |_, count| -count }
      .first(number_of_results)
      .sort
      .to_h
  end

  def without_empty_results(facet)
    facet.reject { |_, count| count.zero? }
  end

  def city_facet
    CITIES.each_with_object({}) { |city, facets| facets[city] = algolia_facet_count(location: city) }
  end

  def county_facet
    COUNTIES.each_with_object({}) { |county, facets| facets[county] = algolia_facet_count(location: county) }
  end

  def education_phase_facet
    School.available_readable_phases.each_with_object({}) { |phase, facets| facets[phase] = algolia_facet_count(phases: [phase]) }
  end

  def job_role_facet
    Vacancy.job_roles.keys.each_with_object({}) { |job_role, facets| facets[job_role] = algolia_facet_count(job_roles: [job_role]) }
  end

  def subject_facet
    SUBJECT_OPTIONS.each_with_object({}) { |subject, facets| facets[subject.first] = algolia_facet_count(keyword: subject.first) }
  end

  def algolia_facet_count(query)
    # Disable this very expensive operation unless caching is enabled (e.g. in dev, system tests)
    return 0 unless Rails.application.config.action_controller.perform_caching

    return 0 if query[:location] && LocationPolygon.none?

    Search::VacancySearch.new(query).total_count || 0
  end
end
