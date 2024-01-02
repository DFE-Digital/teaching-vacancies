class VacancyFilterQuery < ApplicationQuery
  attr_reader :scope

  def initialize(scope = Vacancy.live)
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
    if (filter_job_roles = job_roles(filters[:job_roles]).presence)
      built_scope = built_scope.with_any_of_job_roles(filter_job_roles)
    end
    built_scope = built_scope.ect_suitable if filters[:ect_statuses]&.include?("ect_suitable") || filters[:job_roles]&.include?("ect_suitable")
    built_scope = add_organisation_type_filters(filters, built_scope)
    built_scope = built_scope.quick_apply if filters[:quick_apply]
    built_scope = add_school_type_filters(filters, built_scope)
    working_patterns = fix_legacy_working_patterns(filters[:working_patterns])
    built_scope = built_scope.with_any_of_working_patterns(working_patterns) if working_patterns.present?

    built_scope = built_scope.with_any_of_phases(phases(filters[:phases])) if phases(filters[:phases]).present?

    built_scope
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
      built_scope.where.not("organisations.gias_data ->> 'ReligiousCharacter (name)' IN (?)", Organisation::NON_FAITH_RELIGIOUS_CHARACTER_TYPES)
                 .or(built_scope.where("organisations.detailed_school_type IN (?)", Organisation::SPECIAL_SCHOOL_TYPES)).distinct
    elsif school_types.include?("faith_school")
      built_scope.where.not("organisations.gias_data ->> 'ReligiousCharacter (name)' IN (?)", Organisation::NON_FAITH_RELIGIOUS_CHARACTER_TYPES).distinct
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

  def phases(filter)
    filter&.map { |phase| phase.in?(%w[middle_deemed_secondary middle_deemed_primary]) ? "middle" : phase }
          &.map { |phase| phase == "all_through" ? "through" : phase }
          &.map { |phase| phase.in?(%w[sixteen_plus 16-19]) ? "sixth_form_or_college" : phase }
          &.reject { |phase| phase.in? %w[not_applicable] }
  end

  def fix_legacy_working_patterns(working_patterns)
    return nil unless working_patterns

    # These are no longer relevant and have no current equivalent
    working_patterns - %w[compressed_hours staggered_hours flexible term_time job_share]
  end
end
