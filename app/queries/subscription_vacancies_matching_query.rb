class SubscriptionVacanciesMatchingQuery
  attr_reader :scope

  # British National Grid SRID (EPSG:27700) is a projected coordinate system used for mapping in Great Britain.
  # It provides coordinates in meters, which is useful for distance calculations, which we need
  # for radius-based searches.
  # It is significantly more accurate for distance calculations in Great Britain that EPSG:3857 (Web Mercator).
  # EPSG:3857 distort distances and areas, especially as you move away from the equator. What would cause a multiplier
  # between 1.5x and 1.7x for radius/buffer distances in our case to get the matches we would expect.
  BRITISH_NATIONAL_GRID_SRID = 27700 # rubocop:disable Style/NumericLiterals

  # Builds the query to find the IDs for the vacancies matching the subscription criteria.
  # The subquery is needed to be able to combine our requirements into a valid single SQL statement:
  # - retrieve unique DISTINCT ON vacancy ids: As the location filter may return the same vacancy multiple times (vacancy for multiple orgs).
  # - order by publish_on DESC to get the most recent vacancies first.
  # - apply a limit if needed over the already ordered vacancies.
  # - be able to call pluck(:id) over the resulting query while combining it by distinct and order by a different attribute.
  #
  # If we didn't need the order by published date, we could just call distinct over the filtered query and be done without
  # a subquery.
  #
  # PERFORMANCE:
  # We do not want to return the whole Vacancy into memory as this query is used by a job that iterates through
  # hundreds of thousands of subscriptions to retrieve the matching ids.
  # Directly retrieving the ids from SQL is way faster and more efficient than loading the Vacancy AR objects into memory
  # and then calling map(&:id).
  def initialize(scope:, subscription:, limit: nil)
    search_criteria = sanitise_search_criteria(subscription.search_criteria)

    # Builds the filtering query based on the subscription criteria
    # Handles the deduplication of vacancies.
    deduplicated_search = build_query_from_search_criteria(scope, search_criteria, subscription)
      .reorder("vacancies.id, publish_on DESC")
      .select("DISTINCT ON (vacancies.id) vacancies.id, publish_on")
    # Selects only the ids from the deduplicated set
    unique_ids = Vacancy.from("(#{deduplicated_search.to_sql}) AS unique_vacancies")
                        .select("unique_vacancies.id")
                        .order("unique_vacancies.publish_on DESC")

    @scope = limit ? unique_ids.limit(limit) : unique_ids
  end

  # Triggers the query and returns the matching vacancy IDs
  # we use unique vacancies as a table as we aliased it on the subquery selection.
  def call
    scope.pluck("unique_vacancies.id")
  end

  private

  # Massage the subscription search criteria to be in a format suitable for building the query.
  def sanitise_search_criteria(search_criteria)
    criteria = search_criteria.symbolize_keys.except(:jobs_sort, :job_title, :minimum_salary) # TO DO: Could we delete this from the DB?
    criteria[:job_roles] = sanitise_job_roles(criteria) if Subscription::JOB_ROLE_ALIASES.any? { |role_alias| criteria.key?(role_alias) }
    criteria[:phases] = sanitise_phases(criteria) if criteria[:phases]
    criteria[:working_patterns] = sanitise_working_patterns(criteria) if criteria[:working_patterns]
    # Remove aliases from criteria. They have been merged into 'job_roles' key (that is not excluded and used for query)
    criteria.except!(*Subscription::JOB_ROLE_ALIASES)
  end

  # Goes through the search criteria filters and applies them to the scope one by one, building up the SQL query used
  # to find the matching vacancies for the subscription.
  def build_query_from_search_criteria(scope, search_criteria, subscription)
    search_criteria.each do |criterion, value|
      scope =
        case criterion
        when :job_roles then job_roles_filter(scope, value)
        when :visa_sponsorship_availability then visa_sponsorship_filter(scope, value)
        when :ect_statuses then ect_status_filter(scope, value)
        when :newly_qualified_teacher then newly_qualified_teacher_filter(scope, value)
        when :subjects then subjects_filter(scope, value)
        when :subject then subjects_filter(scope, [value]) # TO DO: This is a legacy single subject criteria. Backfill and remove criteria
        when :phases then phases_filter(scope, value)
        when :working_patterns then working_patterns_filter(scope, value)
        when :organisation_slug then organisation_slug_filter(scope, value)
        when :keyword then keyword_filter(scope, value)
        when :location then location_filter(scope, value, subscription)
        else scope # Ignore unknown criteria
        end
    end
    scope
  end

  # Turns the job_roles from multiple possible criteria keys (aliases) into single job_roles list transformed into
  # array_enum to match DB values (integers) that will be used in the query.
  def sanitise_job_roles(criteria)
    criteria.slice(*Subscription::JOB_ROLE_ALIASES)
            .values
            .flatten
            .filter_map { |jr| Vacancy::JOB_ROLES[jr.to_s] }
  end

  # Turns the phases from string values to to array_enum to match DB values (integers) that will be used in the query.
  def sanitise_phases(criteria)
    Array(criteria[:phases]).filter_map { |ph| Vacancy.phases[ph.to_s] }
  end

  # Handle job_share as a special string, not in enum.
  def sanitise_working_patterns(criteria)
    patterns = Array(criteria[:working_patterns])
    patterns_int = patterns.reject { |p| p == "job_share" }
                           .filter_map { |wp| Vacancy.working_patterns[wp.to_s] } # Map to integer DB values for SQL query
    # Keep job_share string if present, otherwise just use integer array
    if patterns.include?("job_share")
      patterns_int + %w[job_share]
    else
      patterns_int
    end
  end

  # If any of the vacancy's job roles match any of the subscription's job roles
  def job_roles_filter(scope, subscription_job_roles)
    scope.where("job_roles && ARRAY[?]::integer[]", subscription_job_roles)
  end

  def visa_sponsorship_filter(scope, visa_sponsorship_available)
    scope.where(visa_sponsorship_available: visa_sponsorship_available)
  end

  # Where any of the subscription's ect_statuses match the vacancy's ect_status
  def ect_status_filter(scope, subscription_ect_statuses)
    scope.where(ect_status: subscription_ect_statuses)
  end

  # legacy criteria:  value always 'true' if present
  # TO DO: Backfil it to ect_statuses array in the subscriptions table and remove this legacy criteria
  def newly_qualified_teacher_filter(scope, newly_qualified_teacher)
    if newly_qualified_teacher == "true"
      scope.where(ect_status: "ect_suitable")
    else
      scope
    end
  end

  # If any of the vacancy's subjects match any of the subscription's subjects
  def subjects_filter(scope, subscription_subjects)
    scope.where("(subjects && ARRAY[?]::varchar[])", subscription_subjects)
  end

  # If any of the vacancy's phases match any of the subscription's phases
  def phases_filter(scope, subscription_phases)
    scope.where("phases && ARRAY[?]::integer[]", subscription_phases)
  end

  def working_patterns_filter(scope, subscription_patterns)
    if subscription_patterns == %w[job_share] # If only job_share working pattern. Use specific filter.
      scope.where(is_job_share: true)
    elsif subscription_patterns.include?("job_share") # Either is job_share or any of the other working patterns match.
      patterns = subscription_patterns - %w[job_share]
      scope.where("is_job_share = TRUE OR working_patterns && ARRAY[?]::integer[]", patterns)
    else # If any of the vacancy's working patterns match any of the subscription's working patterns
      scope.where("working_patterns && ARRAY[?]::integer[]", subscription_patterns)
    end
  end

  # When subscriptions are for a particular org new vacancies. The search criteria contains the exact org. slug.
  def organisation_slug_filter(scope, organisation_slug)
    scope.joins(:organisations).where(organisations: { slug: organisation_slug })
  end

  # Filter ensuring that for the subscription keywords, all keywords are present in the vacancy's searchable_content
  # Using 'simple' config in the tsquery instead of 'english' to avoid some words not being matched.
  # We only need a "is every keyword included in the searchable content?" match.
  def keyword_filter(scope, subscription_keywords)
    scope.where("vacancies.searchable_content @@ plainto_tsquery('simple', ?)", subscription_keywords.downcase.strip)
  end

  # If the subscription search criteria has a 'within this distance from this location' filter,
  # we need to filter the vacancies based on whether their organisations locations fall within the subscription's area
  # or radius distance from subscription geopoint. Depending if the subscription location matches a polygon or not will
  #  have either an area (polygon with radius buffer) or a geopoint + radius to filter by.
  def location_filter(scope, subscription_location, subscription)
    location = subscription_location.to_s.strip.downcase
    return scope.none if location.blank? # Invalid location filter returns no matches
    return scope if LocationQuery::NATIONWIDE_LOCATIONS.include?(location) # Nationwide location ignores location filtering

    # 'area_before_type_cast' and 'geopoint_before_type_cast' are used to avoid casting the fields into RGeo objects.
    # This reduces memory usage and speeds up the query. As we don't need to use the actual objects in Ruby code,
    # just need to know if they are present in DB.
    if subscription.area_before_type_cast.present?
      location_by_area_filter(scope, subscription)
    elsif subscription.geopoint_before_type_cast.present? && subscription.radius_in_metres.present?
      location_by_geopoint_filter(scope, subscription)
    else
      scope.none # Invalid location filter (having no area or geopoint) returns no matches
    end
  end

  # Filter vacancies where their organisations' geopoints fall within the subscription's area polygon.
  # The subscription area is already buffered by the subscription radius when created/updated.
  # So a "london" + 10 miles subscription will have an area polygon that is London polygon + 10 miles buffer.
  # Any vacancy with an organisation geopoint within that buffered area polygon will match.
  #
  # PERFORMANCE: We cast the organisations.geopoint to geometry to ensure the ST_Contains is a geometry operation.
  # This is significantly faster than geography operations for this type of query.
  #
  # Including 'publish_on' in the distinct: The provided scope may be ordered by publish on date. When using distinct
  # with ordering, Postgres requires all selected columns to be included in the distinct clause or will fail during execution.
  def location_by_area_filter(scope, subscription)
    scope.joins("INNER JOIN subscriptions ON subscriptions.id = '#{subscription.id}'")
         .joins(:organisations)
         .where("ST_Contains(subscriptions.area, organisations.geopoint::geometry)")
  end

  # Filter vacancies where their organisations' geopoints fall within the subscription's radius from the subscription's
  # geopoint.
  # PERFORMANCE:
  #  - We transform both geopoints to British National Grid SRID (27700) to ensure the ST_DWithin is done in metres.
  #  - We cast the organisations.geopoint (stored as geography) to geometry to ensure the ST_DWithin is a geometry
  #    operation. This is significantly faster than using geography types for this type of query.
  #
  # Including 'publish_on' in the distinct: The provided scope may be ordered by publish on date. When using distinct
  # with ordering, Postgres requires all selected columns to be included in the distinct clause or will fail during execution.
  def location_by_geopoint_filter(scope, subscription)
    scope.joins("INNER JOIN subscriptions ON subscriptions.id = '#{subscription.id}'")
         .joins(:organisations)
         .where("ST_DWithin(ST_Transform(organisations.geopoint::geometry, #{BRITISH_NATIONAL_GRID_SRID}),
                            ST_Transform(subscriptions.geopoint, #{BRITISH_NATIONAL_GRID_SRID}),
                            subscriptions.radius_in_metres)")
  end
end
