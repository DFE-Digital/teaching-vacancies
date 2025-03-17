class VacancyFilterQuery < ApplicationQuery
  attr_reader :scope

  def initialize(scope = Vacancy.all)
    @scope = scope
  end

  # TODO: Refactor this to be cleaner - e.g. moving from/to_date into their own scope
  def call(filters) # rubocop:disable Metrics/AbcSize
    from_date = filters[:from_date]&.to_time
    to_date = filters[:to_date]&.to_time

    built_scope = scope

    # Job alert specific filters
    built_scope = built_scope.where(publish_on: (from_date..)) if from_date
    built_scope = built_scope.where(publish_on: (..to_date)) if to_date
    built_scope = built_scope.where("vacancies.subjects && ARRAY[?]::varchar[]", filters[:subjects]) if filters[:subjects].present?

    # General filters
    built_scope = built_scope.visa_sponsorship_available if filters[:visa_sponsorship_availability]

    job_role_keys = %i[job_roles teaching_job_roles support_job_roles]
    built_scope = apply_job_roles(job_role_keys, built_scope, filters)

    built_scope = built_scope.ect_suitable if filters[:ect_statuses]&.include?("ect_suitable") || filters[:job_roles]&.include?("ect_suitable")
    built_scope = add_organisation_type_filters(filters, built_scope)
    built_scope = built_scope.quick_apply if filters[:quick_apply]
    built_scope = add_school_type_filters(filters, built_scope)
    built_scope = add_working_patterns_filters(filters[:working_patterns], built_scope)
    add_phases_filters(filters[:phases], built_scope)
  end

  private

  def add_organisation_type_filters(filters, built_scope)
    return built_scope unless filters[:organisation_types].present?

    selected_school_types = []

    if filters[:organisation_types].include?("Academy")
      selected_school_types.push("Academy", "Academies", "Free schools", "Free school")
    end

    if filters[:organisation_types].include?("Local authority maintained schools")
      selected_school_types << "Local authority maintained schools"
    end

    built_scope.joins(organisation_vacancies: :organisation).where(organisations: { school_type: selected_school_types }).distinct
  end

  def add_school_type_filters(filters, built_scope)
    school_types = filters[:school_types]
    return built_scope unless school_types.present?

    built_scope = built_scope.joins(organisation_vacancies: :organisation)

    if school_types.include?("faith_school") && school_types.include?("special_school")
      built_scope.merge(Organisation.only_faith_schools)
                 .or(built_scope.where("organisations.detailed_school_type IN (?)", Organisation::SPECIAL_SCHOOL_TYPES)).distinct
    elsif school_types.include?("faith_school")
      built_scope.merge(Organisation.only_faith_schools).distinct
    elsif school_types.include?("special_school")
      built_scope.where(organisations: { detailed_school_type: Organisation::SPECIAL_SCHOOL_TYPES }).distinct
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

  def add_working_patterns_filters(working_patterns, built_scope)
    return built_scope if working_patterns.blank?

    # Removes working patterns not defined in the model enumerable values (EG: legacy working patterns)
    # Watch out: any legacy non-enum defined working patterns mapping must be done before this call.
    working_patterns &= Vacancy.working_patterns.keys
    return built_scope if working_patterns.empty?

    # ALERT: "job_share" is still defined in Vacancy.working_patterns enum. If removed from there these mappings need to
    # happen BEFORE to the cleanup above.
    if working_patterns == %w[job_share]
      built_scope.where(is_job_share: true)
    elsif working_patterns.include?("job_share")
      built_scope.where(is_job_share: true).or(built_scope.with_any_of_working_patterns(working_patterns - %w[job_share]))
    else
      built_scope.with_any_of_working_patterns(working_patterns)
    end
  end

  def add_phases_filters(phases, built_scope)
    return built_scope if phases.blank?

    # Removes phases not defined in the model enumerable values (EG: legacy phases)
    # Watch out: any legacy non-enum defined phases mapping must be done before this call.
    phases &= Vacancy.phases.keys
    if phases.any?
      built_scope.with_any_of_phases(phases)
    else
      built_scope
    end
  end

  def apply_job_roles(keys, built_scope, filters)
    filtered_roles_as_strings = keys.flat_map { |key|
      job_roles(filters[key])
    }.compact

    return built_scope if filtered_roles_as_strings.blank?

    filtered_roles_as_integers = filtered_roles_as_strings.map { |role| Vacancy::JOB_ROLES[role] }

    built_scope.where("job_roles && ARRAY[?]::integer[]", filtered_roles_as_integers)
  end
end
