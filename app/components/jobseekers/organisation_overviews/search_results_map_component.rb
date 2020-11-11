class Jobseekers::OrganisationOverviews::SearchResultsMapComponent < Jobseekers::OrganisationOverviews::BaseComponent
  attr_reader :vacancies

  def initialize(vacancies:, vacancies_search:)
    @vacancies = vacancies
    @vacancies_search = vacancies_search
    @polygon_coordinates = polygon_coordinates
  end

  def vacancies_map_data
    data = []
    vacancies.map do |vacancy|
      organisation = vacancy.parent_organisation
      data.push({ name: vacancy.job_title,
                  name_link: link_to(vacancy.job_title, vacancy_path(vacancy)),
                  location: location(organisation, job_location: vacancy.job_location),
                  lat: organisation.geolocation&.x,
                  lng: organisation.geolocation&.y })
    end
    data.to_json
  end

  def render?
    polygon_coordinates.present? || (radius.present? && @vacancies_search.point_coordinates.present?)
  end

  def polygon_coordinates
    return unless @vacancies_search.location_search.polygon_coordinates.present?

    polygon = @vacancies_search.location_search.polygon_coordinates.first
                  .each_slice(2).to_a.map { |element| {lat: element.first, lng: element.second} }
    polygon.to_json
  end

  def radius
    @vacancies_search.radius
  end

  def point_coordinates
    return unless @vacancies_search.point_coordinates.present?

    { lat: @vacancies_search.point_coordinates.first, lng: @vacancies_search.point_coordinates.second }.to_json
  end

  def show_polygon_buttons?
    polygon_coordinates.present?
  end

  def polygon_editable?
    @vacancies_search.user_input_polygon_search?.to_s
  end
end
