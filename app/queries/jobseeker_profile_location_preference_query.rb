class JobseekerProfileLocationPreferenceQuery < ApplicationQuery
  attr_reader :scope

  def initialize(scope = JobseekerProfile.all)
    @scope = scope
  end

  def call(organisation)
    scope.where("ST_DWithin(jobseeker_profiles.location_preference, ?, ?)", organisation.geopoint, 0)
  end
end
