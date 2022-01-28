class Jobseekers::OrganisationOverviews::SchoolsComponent < Jobseekers::OrganisationOverviews::BaseComponent
  def render?
    vacancy.at_multiple_schools?
  end

  def map_links
    vacancy.organisations.each do |organisation|
      @links.push({ text: "#{organisation.name}, #{full_address(organisation)}", url: organisation_url(organisation), id: organisation.id })
    end
  end
end
