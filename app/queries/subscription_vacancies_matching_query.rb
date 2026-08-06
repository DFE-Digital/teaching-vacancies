class SubscriptionVacanciesMatchingQuery
  # PERFORMANCE:
  # The caller of this method just needs to add .pluck(:id) (rather than map(&:id))
  # to ensure that vacancies doesn't get loaded into RAM by mistake
  class << self
    def call(scope:, subscription:, limit:)
      search_criteria = sanitise_search_criteria(subscription.search_criteria).symbolize_keys
      if search_criteria[:keyword].present?
        scope = scope.search_by_full_text(search_criteria.fetch(:keyword))
      end
      if search_criteria.key?(:location) && search_criteria.key?(:radius)
        scope = scope.search_by_location(search_criteria.fetch(:location), search_criteria.fetch(:radius), polygon: nil, sort_by_distance: false)
      end
      # search_by_filter doesn't suuport filter by slug
      if search_criteria.key?(:organisation_slug)
        scope = organisation_slug_filter(scope, search_criteria.fetch(:organisation_slug))
      end
      scope.search_by_filter(search_criteria).limit(limit).order(publish_on: :desc)
    end

    private

    # Massage the subscription search criteria to be in a format suitable for building the query.
    def sanitise_search_criteria(search_criteria)
      criteria = search_criteria.symbolize_keys.except(:jobs_sort, :job_title, :minimum_salary) # TO DO: Could we delete this from the DB?
      criteria[:job_roles] = sanitise_job_roles(criteria) if Subscription::JOB_ROLE_ALIASES.any? { |role_alias| criteria.key?(role_alias) }
      # handle legacy filters
      criteria[:ect_statuses] = %w[ect_suitable] if criteria[:newly_qualified_teacher] == "true"
      if criteria.key?(:subject)
        criteria[:subjects] = [criteria[:subject]]
      end
      # Remove aliases from criteria. They have been merged into 'job_roles' key (that is not excluded and used for query)
      criteria.except(*Subscription::JOB_ROLE_ALIASES)
    end

    # Turns the job_roles from multiple possible criteria keys (aliases) into single job_roles list transformed into
    # array_enum to match DB values (integers) that will be used in the query.
    def sanitise_job_roles(criteria)
      criteria.slice(*Subscription::JOB_ROLE_ALIASES)
              .values
              .flatten
    end

    # When subscriptions are for a particular org new vacancies. The search criteria contains the exact org. slug.
    def organisation_slug_filter(scope, organisation_slug)
      scope.joins(:organisations).where(organisations: { slug: organisation_slug })
    end
  end
end
