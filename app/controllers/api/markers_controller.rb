class Api::MarkersController < Api::ApplicationController
  include VacanciesHelper
  include OrganisationsHelper
  include DatesHelper

  before_action :verify_json_request, only: %i[show]
  before_action :check_valid_params, only: %i[show]

  def show
    render json: {
      heading_text: heading_text,
      heading_url: heading_url,
      anonymised_id: anonymised_id,
      name: organisation.name,
      address: full_address(organisation),
      description: description,
      details: details,
    }
  end

  private

  def vacancy
    @vacancy ||= Vacancy.find(params[:id])
  end

  def organisation
    @organisation ||= Organisation.find(params[:parent_id])
  end

  def heading_text
    params[:marker_type] == "vacancy" ? vacancy.job_title : organisation.name
  end

  def heading_url
    params[:marker_type] == "vacancy" ? job_path(vacancy) : organisation.url
  end

  def anonymised_id
    StringAnonymiser.new(vacancy.id).to_s
  end

  def description
    organisation_type(organisation) if params[:marker_type] == "organisation"
  end

  def details
    return if params[:marker_type] == "organisation"

    [
      { label: t("jobs.annual_salary"), value: vacancy.salary },
      { label: t("jobs.school_type"), value: vacancy.readable_phases.map(&:capitalize).join(", ") },
      { label: t("jobs.working_patterns"), value: working_patterns(vacancy) },
      { label: t("jobs.expires_at"), value: format_time_to_datetime_at(vacancy.expires_at) },
    ].select { |d| d[:value].present? }
  end

  def check_valid_params
    return render(json: { error: "Missing params" }, status: :bad_request) unless params[:parent_id] && params[:marker_type]
  end
end
