# Based on a vacancy, devise a plausible set of search criteria for a job alert subscription
class Search::CriteriaInventor
  DEFAULT_RADIUS_IN_MILES = 25

  def initialize(vacancy)
    @vacancy = vacancy
  end

  def criteria
    @criteria ||= {
      location: location,
      radius: (location.present? ? DEFAULT_RADIUS_IN_MILES.to_s : nil),
      working_patterns: [],
      phases: @vacancy.readable_phases,
      job_roles: [@vacancy.job_role],
      ect_statuses: [@vacancy.ect_status],
      subjects: subjects,
    }.delete_if { |_k, v| v.blank? }
  end

  private

  def location
    # We override the name method for local authorities
    return @vacancy.organisation.read_attribute(:name) if @vacancy.organisation.local_authority?

    @vacancy.organisation.postcode
  end

  def subjects
    @vacancy.subjects if @vacancy.job_role.in?(%w[teacher middle_leader])
  end
end
