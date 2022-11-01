class Search::JobseekerProfileSearch
  def initialize(organisation)
    @organisation = organisation
  end

  def jobseekers
    scope = JobseekerProfile.all
    scope.search_by_organisation_inclusion_in_location_preference_area(@organisation)
  end
end
