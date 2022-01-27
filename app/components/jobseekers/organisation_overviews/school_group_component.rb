class Jobseekers::OrganisationOverviews::SchoolGroupComponent < Jobseekers::OrganisationOverviews::BaseComponent
  def render?
    vacancy.central_office?
  end

  def map_links
    @links.push({ text: "#{organisation.name}, #{full_address(organisation)}", url: organisation_url(organisation), id: organisation.id })
  end
end
