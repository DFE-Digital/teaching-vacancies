class Jobseekers::OrganisationOverviews::SchoolGroupComponent < Jobseekers::OrganisationOverviews::BaseComponent
  def render?
    vacancy.central_office?
  end
end
