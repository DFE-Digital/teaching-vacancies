class Jobseekers::OrganisationOverviews::SchoolsComponent < Jobseekers::OrganisationOverviews::BaseComponent
  include MapHelper

  def render?
    vacancy.at_multiple_schools?
  end

  def organisation_map_data
    markers = []
    vacancy.organisations.select(&:geopoint).each do |school|
      markers.push(marker(school.geopoint.lat, school.geopoint.lon, { name: school.name,
                     name_link: link_to(school.name, (school.website || school.url)),
                     address: full_address(school),
                     school_type: organisation_type(school) }))
    end
    { markers: markers.to_json }.to_json
  end
end
