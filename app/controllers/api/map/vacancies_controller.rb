class Api::Map::VacanciesController < Api::ApplicationController
  include OrganisationsHelper

  before_action :verify_json_request, only: %i[show]

  def show
    render json: markers
  end

  private

  def markers
    Vacancy.find(params[:id])
           .organisations
           .select(&:geopoint)
           .map { |organisation| marker(organisation) }
  end

  def marker(organisation)
    {
      type: "marker",
      data: {
        point: [organisation.geopoint.lat, organisation.geopoint.lon],
        meta: {
          id: organisation.id,
          name: organisation.name,
          name_link: organisation.website || organisation.url,
          address: full_address(organisation),
          organisation_type: organisation_type(organisation),
        },
      },
    }
  end
end
