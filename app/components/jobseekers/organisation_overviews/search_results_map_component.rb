class Jobseekers::OrganisationOverviews::SearchResultsMapComponent < Jobseekers::OrganisationOverviews::BaseComponent
  attr_reader :polygon, :vacancies

  def initialize(polygon:, vacancies:)
    @polygon = polygon
    @vacancies = vacancies
  end

  def organisations_map_data
    organisations = []
    vacancies.map do |vacancy|
      organisation = vacancy.parent_organisation
      organisations.push({name: organisation.name,
                          name_link: link_to(organisation.name, (organisation.website || organisation.url)),
                          address: full_address(organisation),
                          location: location(organisation, job_location: vacancy.job_location),
                          lat: organisation.geolocation&.x,
                          lng: organisation.geolocation&.y})
    end
    organisations.to_json
  end

  def render?
    @polygon.present?
  end
end
