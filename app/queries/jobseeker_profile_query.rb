class JobseekerProfileQuery
  def initialize(filters, organisation)
    @filters = filters
    @organisation = organisation
  end

  def call
    jobseeker_profiles_scope = JobseekerProfile.active.where(id: job_preferences_after_filters.select(:jobseeker_profile_id))
    jobseeker_profiles_scope = jobseeker_profiles_scope.where(qualified_teacher_status: qts_database_values) if filters[:qualified_teacher_status].present?

    jobseeker_profiles_scope
  end

  private

  attr_reader :filters, :organisation

  def qts_database_values
    filters[:qualified_teacher_status]
      &.map { |qts| qts == "awarded" ? "yes" : qts }
      &.map { |qts| qts == "none" ? "no" : qts }
  end

  def job_preferences_after_filters
    job_preferences_scope = job_preferences_in_school_location
    job_preferences_scope = job_preferences_scope.where("job_preferences.roles && ARRAY[?]::varchar[]", filters[:roles]) if filters[:roles].present?
    job_preferences_scope = job_preferences_scope.where("job_preferences.working_patterns && ARRAY[?]::varchar[]", filters[:working_patterns]) if filters[:working_patterns].present?
    job_preferences_scope = job_preferences_scope.where("job_preferences.phases && ARRAY[?]::varchar[]", filters[:phases]) if filters[:phases].present?
    job_preferences_scope = job_preferences_scope.where("job_preferences.key_stages && ARRAY[?]::varchar[]", filters[:key_stages]) if filters[:key_stages].present?

    job_preferences_scope
  end

  def job_preferences_in_school_location
    JobPreferences.where(id: ::JobPreferences::Location.containing(organisation.geopoint).select(:job_preferences_id))
  end
end
