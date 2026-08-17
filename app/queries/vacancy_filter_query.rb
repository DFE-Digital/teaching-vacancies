class VacancyFilterQuery
  FILTERS = {
    # Job alert specific filters
    from_date: ->(from_date) { Vacancy.where(publish_on: (from_date.to_time..)) },
    to_date: ->(to_date) { Vacancy.where(publish_on: (..to_date.to_time)) },
    subjects: ->(subjects) { Vacancy.where("vacancies.subjects && ARRAY[?]::varchar[]", subjects) },
    # General filters
    visa_sponsorship_availability: ->(_) { Vacancy.visa_sponsorship_available },
    ect_statuses: ->(filter) { ect_filter_scope(filter) },
    organisation_types: ->(filter) { organisation_type_filters(filter) },
    quick_apply: ->(_) { Vacancy.quick_apply },
    school_types: ->(filter) { school_type_filters(filter) },
    working_patterns: ->(filter) { working_patterns_filters(filter) },
    phases: ->(filter) { phases_filters(filter) },
  }.freeze

  class << self
    def call(scope, filters)
      job_roles_scope = job_roles_filters(%i[job_roles teaching_job_roles support_job_roles], filters)
      scopes = FILTERS.slice(*filters.keys)
                      .map { |key, function| function.call(filters.fetch(key)) } + [job_roles_scope]

      scopes
        .compact
        .reduce(scope) do |accum_scope, vacancy_scope|
        accum_scope.merge(vacancy_scope)
      end
    end

    private

    def ect_filter_scope(ect_filters)
      built_scope = Vacancy.joins(:organisations)

      if ect_filters.include?("ect_suitable") && ect_filters.include?("qts_not_needed")
        built_scope.merge(Vacancy.ect_suitable)
                   .or(built_scope.merge(Organisation.colleges).qts_not_needed).distinct
      elsif ect_filters.include?("ect_suitable")
        built_scope.merge(Vacancy.ect_suitable).distinct
      elsif ect_filters.include?("qts_not_needed")
        built_scope.merge(Organisation.colleges).qts_not_needed.distinct
      else
        built_scope
      end
    end

    def organisation_type_filters(organisation_types)
      selected_school_types = []

      if organisation_types.include?("Academy")
        selected_school_types.push(School::ACADEMY_TYPE, School::FREE_SCHOOL_TYPE)
      end

      if organisation_types.include?("Local authority maintained schools")
        selected_school_types << School::LA_SCHOOL_TYPE
      end

      if organisation_types.include?("FE Colleges")
        selected_school_types << School::COLLEGE_SCHOOL_TYPE
      end

      Vacancy.joins(organisation_vacancies: :organisation).where(organisations: { school_type: selected_school_types }).distinct
    end

    def school_type_filters(school_types)
      built_scope = Vacancy.joins(:organisations)

      if school_types.include?("faith_school") && school_types.include?("special_school")
        built_scope.merge(Organisation.faith_schools)
                   .or(built_scope.merge(Organisation.where(detailed_school_type: Organisation::SPECIAL_SCHOOL_TYPES))).distinct
      elsif school_types.include?("faith_school")
        built_scope.merge(Organisation.faith_schools).distinct
      elsif school_types.include?("special_school")
        built_scope.merge(Organisation.where(detailed_school_type: Organisation::SPECIAL_SCHOOL_TYPES)).distinct
      else
        built_scope
      end
    end

    # Keeps compatibility with legacy job roles filters that have been removed but they are still used by users.
    # EG: Bookmarked results page for a search with the old job roles filters.
    # EG2: Job alerts with the old job roles filters.
    def map_legacy_job_roles(job_roles)
      job_roles.flat_map do |job_role|
        case job_role
        when "leadership", "senior_leader" then Vacancy::SENIOR_LEADER_JOB_ROLES
        when "middle_leader" then Vacancy::MIDDLE_LEADER_JOB_ROLES
        else job_role
        end
      end
    end

    def job_roles(filter)
      return if filter.blank?

      map_legacy_job_roles(filter).reject { |job_role| Vacancy.job_roles.exclude? job_role } # Avoids exceptions raised by ArrayEnum when the job role is not valid
    end

    def working_patterns_filters(working_patterns)
      # Removes working patterns not defined in the model enumerable values (EG: legacy working patterns)
      # Watch out: any legacy non-enum defined working patterns mapping must be done before this call.
      working_patterns &= Vacancy.working_patterns.keys
      return nil if working_patterns.empty?

      # ALERT: "job_share" is still defined in Vacancy.working_patterns enum. If removed from there these mappings need to
      # happen BEFORE to the cleanup above.
      if working_patterns == %w[job_share]
        Vacancy.where(is_job_share: true)
      elsif working_patterns.include?("job_share")
        Vacancy.where(is_job_share: true).or(Vacancy.with_any_of_working_patterns(working_patterns - %w[job_share]))
      else
        Vacancy.with_any_of_working_patterns(working_patterns)
      end
    end

    def phases_filters(phases)
      # Removes phases not defined in the model enumerable values (EG: legacy phases)
      # Watch out: any legacy non-enum defined phases mapping must be done before this call.
      phases &= Vacancy.phases.keys
      if phases.any?
        Vacancy.with_any_of_phases(phases)
      end
    end

    def job_roles_filters(keys, filters)
      filtered_roles_as_strings = keys.flat_map { |key|
        job_roles(filters[key])
      }.compact

      return nil if filtered_roles_as_strings.blank?

      filtered_roles_as_integers = filtered_roles_as_strings.map { |role| Vacancy::JOB_ROLES[role] }

      Vacancy.where("job_roles && ARRAY[?]::integer[]", filtered_roles_as_integers)
    end
  end
end
