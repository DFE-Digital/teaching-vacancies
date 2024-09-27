class Search::JobseekerProfileSearch
  attr_reader :filters

  def initialize(current_organisation:, filters:)
    @filters = filters
    @current_organisation = current_organisation
  end

  def jobseeker_profiles # rubocop:disable Metrics/AbcSize
    scope = JobseekerProfile
              .includes(:job_preferences)
              .includes(:personal_details)
              .joins(job_preferences: :locations)
              .left_outer_joins(:personal_details)
              .active.not_hidden_from(current_organisation)
              .merge(location_preferences)

    scope = filter_by_qts(scope) if filters[:qualified_teacher_status].present?
    scope = scope.where("job_preferences.roles && ARRAY[?]::varchar[]", roles_filter) if roles_filter.present?
    scope = scope.where("job_preferences.working_patterns && ARRAY[?]::varchar[]", filters[:working_patterns]) if filters[:working_patterns].present?
    scope = scope.where("job_preferences.phases && ARRAY[?]::varchar[]", filters[:education_phases]) if filters[:education_phases].present?
    scope = scope.where("job_preferences.key_stages && ARRAY[?]::varchar[]", filters[:key_stages]) if filters[:key_stages].present?
    scope = scope.where("job_preferences.subjects && ARRAY[?]::varchar[]", filters[:subjects]) if filters[:subjects].present?
    scope = scope.where("personal_details.right_to_work_in_uk = ?", right_to_work_in_uk) if one_option_selected_for_right_to_work_in_uk?
    scope
  end

  def roles_filter
    role_filters = %i[teaching_job_roles support_job_roles]

    role_filters.flat_map { |filter_type| filters[filter_type] }.compact
  end

  def total_count
    jobseeker_profiles.count
  end

  def total_filters
    filter_counts = %i[qualified_teacher_status teaching_job_roles support_job_roles working_patterns education_phases key_stages subjects right_to_work_in_uk].map { |filter| @filters[filter]&.count || 0 }
    filter_counts.sum
  end

  def clear_filters_params
    @filters.merge({ qualified_teacher_status: [], teaching_job_roles: [], support_job_roles: [], working_patterns: [], education_phases: [], key_stages: [], subjects: [], right_to_work_in_uk: [] })
  end

  def filter_by_qts(scope)
    if filters[:qualified_teacher_status].include?("no")
      selected_statuses = filters[:qualified_teacher_status] << "non_teacher"
      return scope.where(qualified_teacher_status: selected_statuses).or(scope.where(qualified_teacher_status: nil))
    end

    scope.where(qualified_teacher_status: filters[:qualified_teacher_status])
  end

  private

  attr_reader :current_organisation

  def one_option_selected_for_right_to_work_in_uk?
    filters[:right_to_work_in_uk].present? && filters[:right_to_work_in_uk].count == 1
  end

  def right_to_work_in_uk
    filters[:right_to_work_in_uk].first == "true"
  end

  def location_preferences
    if current_organisation.school?
      JobPreferences::Location.containing(current_organisation.geopoint)
    elsif filters[:locations].present?
      School.where(id: filters[:locations])
            .map { |school| JobPreferences::Location.containing(school.geopoint) }
            .reduce { |q, item| q.or(item) }
    else
      current_organisation.schools
            .map { |school| JobPreferences::Location.containing(school.geopoint) }
            .reduce { |q, item| q.or(item) }
    end
  end
end
