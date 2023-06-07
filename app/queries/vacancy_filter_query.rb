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
    built_scope = built_scope.where(job_role: job_roles(filters[:job_roles])) if job_roles(filters[:job_roles]).present?
    built_scope = built_scope.ect_suitable if filters[:ect_statuses]&.include?("ect_suitable") || filters[:job_roles]&.include?("ect_suitable")
    # TODO: Remove this scope when we do not have any more live SEND responsible jobs
    built_scope = built_scope.where(":job_roles = ANY (job_roles)", job_roles: 2) if filters[:job_roles]&.include?("send_responsible")
    built_scope = add_organisation_type_filters(filters, built_scope)
    working_patterns = fix_legacy_working_patterns(filters[:working_patterns])
    built_scope = built_scope.with_any_of_working_patterns(working_patterns) if working_patterns.present?

    built_scope = built_scope.with_any_of_phases(phases(filters[:phases])) if phases(filters[:phases]).present?

    built_scope
  end

  def add_organisation_type_filters(filters, built_scope)
    return built_scope unless filters[:organisation_types].present?

    establishment_code_filter = []
    establishment_name_filter = []

    if filters[:organisation_types].include?("academy")
      %w[10 11].each { |code| establishment_code_filter << code }
      ["Academies", "Free Schools"].each { |name| establishment_name_filter << name }
    end

    if filters[:organisation_types].include?("local_authority")
      establishment_code_filter << "4"
      establishment_name_filter << "Local authority maintained schools"
    end

    built_scope.joins(organisation_vacancies: :organisation).where("(gias_data->>'EstablishmentTypeGroup (code)' IN (?) OR gias_data->>'EstablishmentTypeGroup (name)' IN (?))", establishment_code_filter, establishment_name_filter)
  end

  private

  def organisation_type_filter_selected?(filters)
    filters[:organisation_types].present?
  end

  def both_are_selected?(filters)
    filters[:organisation_types].try(:length) == 2
  end

  def establishment_type_group_codes_selected(filters); end

  def job_roles(filter)
    filter&.map { |job_role| job_role == "sen_specialist" ? "sendco" : job_role }
          &.map { |job_role| job_role == "leadership" ? "senior_leader" : job_role }
          &.reject { |job_role| job_role.in? %w[ect_suitable send_responsible] }
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
    working_patterns - %w[compressed_hours staggered_hours]
  end
end
