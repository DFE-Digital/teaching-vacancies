class VacancyFilterQuery < ApplicationQuery
  attr_reader :scope

  def initialize(scope = Vacancy.live)
    @scope = scope
  end

  # TODO: Refactor this to be cleaner - e.g. moving from/to_date into their own scope
  def call(filters)
    from_date = filters[:from_date]&.to_time
    to_date = filters[:to_date]&.to_time

    built_scope = scope

    # Job alert specific filters
    built_scope = built_scope.where(publish_on: (from_date..)) if from_date
    built_scope = built_scope.where(publish_on: (..to_date)) if to_date
    built_scope = built_scope.where("subjects && ARRAY[?]::varchar[]", filters[:subjects]) if filters[:subjects].present?

    # General filters
    job_roles = fix_legacy_job_roles(filters[:job_roles])
    built_scope = built_scope.with_any_of_job_roles(job_roles) if job_roles.present?

    working_patterns = fix_legacy_working_patterns(filters[:working_patterns])
    built_scope = built_scope.with_any_of_working_patterns(working_patterns) if working_patterns.present?

    built_scope = built_scope.where("readable_phases && ARRAY[?]::varchar[]", filters[:phases]) if filters[:phases].present?

    built_scope
  end

  private

  def fix_legacy_job_roles(job_roles)
    return nil unless job_roles

    job_roles.dup.tap do |roles|
      roles.push("ect_suitable") if roles.delete("nqt_suitable")
      roles.push("send_responsible") if roles.delete("sen_specialist")
    end
  end

  def fix_legacy_working_patterns(working_patterns)
    return nil unless working_patterns

    # These are no longer relevant and have no current equivalent
    working_patterns - %w[compressed_hours staggered_hours]
  end
end
