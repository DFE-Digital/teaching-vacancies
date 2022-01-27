class Jobseekers::OrganisationOverviews::SchoolComponent < Jobseekers::OrganisationOverviews::BaseComponent
  def render?
    vacancy.at_one_school?
  end

  def map_links
    @links.push({ text: "#{organisation.name}, #{full_address(organisation)}", url: organisation_url(organisation), id: organisation.id })
  end
end
