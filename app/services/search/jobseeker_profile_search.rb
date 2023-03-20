class Search::JobseekerProfileSearch
  def initialize(filters)
    @filters = filters
    @current_organisation = filters[:current_organisation]
  end

  def jobseeker_profiles # rubocop:disable Metrics/AbcSize
    scope = JobseekerProfile.includes(:job_preferences).active
    scope = scope.where(job_preferences: { id: location_preferences_ids_matching_location_search })
    scope = scope.where(qualified_teacher_status: filters[:qualified_teacher_status]) if filters[:qualified_teacher_status].present?
    scope = scope.where("job_preferences.roles && ARRAY[?]::varchar[]", filters[:roles]) if filters[:roles].present?
    scope = scope.where("job_preferences.working_patterns && ARRAY[?]::varchar[]", filters[:working_patterns]) if filters[:working_patterns].present?
    scope = scope.where("job_preferences.phases && ARRAY[?]::varchar[]", filters[:education_phases]) if filters[:education_phases].present?
    scope = scope.where("job_preferences.key_stages && ARRAY[?]::varchar[]", filters[:key_stages]) if filters[:key_stages].present?
    scope = scope.where("job_preferences.subjects && ARRAY[?]::varchar[]", filters[:subjects]) if filters[:subjects].present?

    scope
  end

  private

  attr_reader :filters, :current_organisation

  def location_preferences_ids_matching_location_search
    return location_preferences_containing_school(current_organisation) if current_organisation.school?

    return location_preferences_containing_schools(schools_from_filters) if filters[:locations].present?

    location_preferences_containing_schools(current_organisation.schools)
  end

  def location_preferences_containing_school(school)
    JobPreferences::Location.containing(school.geopoint).pluck(:job_preferences_id)
  end

  def location_preferences_containing_schools(schools)
    schools.flat_map { |school| JobPreferences::Location.containing(school.geopoint).uniq.pluck(:job_preferences_id) }
  end

  def schools_from_filters
    School.where(id: filters[:locations])
  end
end
