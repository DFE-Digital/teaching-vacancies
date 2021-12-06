class Jobseekers::OrganisationOverviews::SchoolsComponent < Jobseekers::OrganisationOverviews::BaseComponent
  def render?
    vacancy.at_multiple_schools?
  end
end
