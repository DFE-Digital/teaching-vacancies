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
          name: organisation.name,
          name_link: organisation.website || organisation.url,
          address: full_address(organisation),
          school_type: organisation_type(organisation),
        },
      },
    }
  end
end
