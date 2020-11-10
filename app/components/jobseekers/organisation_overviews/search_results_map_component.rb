class Jobseekers::OrganisationOverviews::SearchResultsMapComponent < Jobseekers::OrganisationOverviews::BaseComponent
  attr_reader :polygon_coordinates, :vacancies

  def initialize(polygon_coordinates:, vacancies:)
    @polygon_coordinates = polygon_coordinates
    @vacancies = vacancies
  end

  def vacancies_map_data
    data = []
    vacancies.map do |vacancy|
      organisation = vacancy.parent_organisation
      data.push({name: vacancy.job_title,
                 name_link: link_to(vacancy.job_title, vacancy_path(vacancy)),
                 location: location(organisation, job_location: vacancy.job_location),
                 lat: organisation.geolocation&.x,
                 lng: organisation.geolocation&.y})
    end
    data.to_json
  end

  def render?
    polygon_coordinates.present?
  end
end
