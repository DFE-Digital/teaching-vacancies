class Jobseekers::OrganisationOverviews::SchoolsComponent < Jobseekers::OrganisationOverviews::BaseComponent
  def render?
    vacancy.at_multiple_schools?
  end

  def organisation_map_data
    schools = []
    vacancy.organisations.select(&:geolocation).each do |school|
      schools.push({ name: school.name,
                     name_link: link_to(school.name, (school.website || school.url)),
                     address: full_address(school),
                     school_type: organisation_type(organisation: school, with_age_range: false),
                     lat: school.geolocation.x,
                     lng: school.geolocation.y })
    end
    schools.to_json
  end
end
