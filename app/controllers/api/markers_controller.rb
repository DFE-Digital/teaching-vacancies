class Api::MarkersController < Api::ApplicationController
  include VacanciesHelper
  include OrganisationsHelper
  include DatesHelper

  before_action :verify_json_request, only: %i[show]

  def show
    render json: {
      heading_text: vacancy.job_title,
      heading_url: job_path(vacancy),
      address: full_address(organisation),
      details: [
        { label: t("jobs.salary"), value: vacancy.salary },
        { label: organisation_type_label(vacancy), value: organisation_type(organisation) },
        { label: t("jobs.working_patterns"), value: working_patterns(vacancy) },
        { label: t("jobs.expires_at"), value: format_time_to_datetime_at(vacancy.expires_at) },
      ],
    }
  end

  private

  def vacancy
    @vacancy ||= Vacancy.listed.find(params[:id])
  end

  def organisation
    @organisation ||= Organisation.find(params[:parent_id])
  end
end
