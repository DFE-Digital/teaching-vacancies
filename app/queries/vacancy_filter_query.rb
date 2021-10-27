class VacancyFilterQuery < ApplicationQuery
  attr_reader :scope

  def initialize(scope = Vacancy.live)
    @scope = scope
  end

  # This query currently takes an identical set of parameters in the hash as the
  # legacy Algolia `FiltersBuilder` to make it possible to run both Algolia and
  # the new DB-based search side by side. Once Algolia is gone for good, we can
  # refactor this to be cleaner - e.g. moving from/to_date into their own scope
  def call(filters)
    from_date = filters[:from_date]&.to_time&.to_i
    to_date = filters[:to_date]&.to_time&.to_i

    built_scope = scope

    # Job alert specific filters
    built_scope = built_scope.where(publish_on: (from_date..)) if from_date
    built_scope = built_scope.where(publish_on: (..to_date)) if to_date
    built_scope = built_scope.where("subjects && ARRAY[?]::varchar[]", filters[:subjects]) if filters[:subjects].present?

    # General filters
    built_scope = built_scope.with_any_of_job_roles(filters[:job_roles]) if filters[:job_roles].present?
    built_scope = built_scope.with_any_of_working_patterns(filters[:working_patterns]) if filters[:working_patterns].present?
    built_scope = built_scope.where("readable_phases && ARRAY[?]::varchar[]", filters[:phases]) if filters[:phases].present?

    built_scope
  end
end
