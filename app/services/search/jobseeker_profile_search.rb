class Search::JobseekerProfileSearch
  def initialize(filters, organisation)
    @filters = filters
    @organisation = organisation
  end

  def jobseeker_profiles # rubocop:disable Metrics/AbcSize
    scope = JobseekerProfile.includes(:job_preferences).active
    scope = scope.where(job_preferences: { id: location_preferences_containing_organisation_ids })
    scope = scope.where(qualified_teacher_status: filters[:qualified_teacher_status]) if filters[:qualified_teacher_status].present?
    scope = scope.where("job_preferences.roles && ARRAY[?]::varchar[]", filters[:roles]) if filters[:roles].present?
    scope = scope.where("job_preferences.working_patterns && ARRAY[?]::varchar[]", filters[:working_patterns]) if filters[:working_patterns].present?
    scope = scope.where("job_preferences.phases && ARRAY[?]::varchar[]", filters[:education_phases]) if filters[:education_phases].present?
    scope = scope.where("job_preferences.key_stages && ARRAY[?]::varchar[]", filters[:key_stages]) if filters[:key_stages].present?

    scope
  end

  private

  attr_reader :filters, :organisation

  def location_preferences_containing_organisation_ids
    return ::JobPreferences::Location.containing(organisation.geopoint).pluck(:job_preferences_id) if organisation.school?

    organisation.schools.flat_map { |school| ::JobPreferences::Location.containing(school.geopoint).uniq.pluck(:job_preferences_id) }
  end
end
