class Jobseekers::OrganisationOverviews::SchoolComponent < Jobseekers::OrganisationOverviews::BaseComponent
  def render?
    vacancy.at_one_school?
  end
end
