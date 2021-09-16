class Jobseekers::OrganisationOverviews::SchoolsComponent < Jobseekers::OrganisationOverviews::BaseComponent
  def render?
    vacancy.at_multiple_schools?
  end

  def organisation_map_data
    schools = []
    vacancy.organisations.select(&:geopoint).each do |school|
      schools.push({ name: school.name,
                     name_link: link_to(school.name, (school.website || school.url)),
                     address: full_address(school),
                     school_type: organisation_type(school),
                     lat: school.geopoint.lat,
                     lng: school.geopoint.lon })
    end
    schools.to_json
  end
end
