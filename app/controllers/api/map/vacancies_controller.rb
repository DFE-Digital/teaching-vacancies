class Api::Map::VacanciesController < Api::ApplicationController
  include OrganisationsHelper

  before_action :verify_json_request, only: %i[show]

  def show
    map_items = []
    vacancy = Vacancy.find(params[:id])

    if params[:type] == 'school'
      map_object = {
        type: "marker",
        data: {
          point: [vacancy.parent_organisation.geopoint&.lat, vacancy.parent_organisation.geopoint&.lon],
          meta: {
            name: vacancy.parent_organisation&.name,
            name_link: vacancy.parent_organisation&.website || vacancy.parent_organisation&.url,
            address: full_address(vacancy.parent_organisation),
            school_type: organisation_type(vacancy.parent_organisation),
          },
        },
      }

      map_items.push(map_object)

    elsif params[:type] == 'organisation'
      vacancy.organisations.select(&:geopoint).each do |school|
        map_items.push({
          type: "marker",
          data: {
            point: [school.geopoint.lat, school.geopoint.lon],
            meta: {
              name: school.name,
              name_link: school.website || school.url,
              address: full_address(school),
              school_type: organisation_type(school),
            },
          },
        })
      end
    end

    render json: map_items
  end
end
