class Publishers::AtsApi::V1::VacanciesController < Api::ApplicationController
  skip_before_action :verify_authenticity_token # API requests don't need CRSF protection.

  before_action :authenticate_client!
  before_action :validate_create_payload, only: %i[create]
  before_action :validate_update_payload, only: %i[update]
  before_action :set_vacancy, only: %i[show update destroy]

  rescue_from StandardError, with: :render_server_error
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from Publishers::AtsApi::OrganisationFetcher::InvalidOrganisationError, with: :render_unprocessable_entity

  def index
    @pagy, @vacancies = pagy(vacancies, items: 100)
    respond_to(&:json)
  end

  def show
    respond_to(&:json)
  end

  def create
    result = Publishers::AtsApi::CreateVacancyService.call(vacancy_params)

    render result.slice(:json, :status)
  end

  def update
    result = Publishers::AtsApi::UpdateVacancyService.call(@vacancy, vacancy_params)

    if result[:status] == :ok
      render :show
    else
      render result.slice(:json, :status)
    end
  end

  def destroy
    @vacancy.trash!
    head :no_content
  end

  private

  def set_vacancy
    @vacancy = Vacancy.find_by!(publisher_ats_api_client: client, id: params[:id])

    raise ActiveRecord::RecordNotFound if @vacancy.trashed?
  end

  def required_vacancy_keys
    %i[
      external_advert_url
      expires_at
      job_title
      job_advert
      salary
      external_reference
      job_roles
      working_patterns
      contract_type
      phases
      schools
    ]
  end

  # rubocop:disable Metrics/MethodLength
  def permitted_vacancy_params
    params.fetch(:vacancy)
          .permit(:job_title,
                  :job_advert,
                  :external_advert_url,
                  :external_reference,
                  :expires_at,
                  :contract_type,
                  :salary,
                  :visa_sponsorship_available,
                  :is_job_share,
                  :ect_suitable,
                  :publish_on,
                  :benefits_details,
                  :starts_on,
                  job_roles: [],
                  working_patterns: [],
                  phases: [],
                  key_stages: [],
                  subjects: [],
                  schools: [
                    :trust_uid,
                    { school_urns: [] },
                  ])
  end
  # rubocop:enable Metrics/MethodLength

  def vacancy_params
    permitted_vacancy_params.merge(publisher_ats_api_client_id: client.id)
  end

  def vacancies
    Vacancy
      .includes(:organisations)
      .order(publish_on: :desc)
      .where(publisher_ats_api_client: client)
      .where.not(status: Vacancy.statuses[:trashed])
  end

  def client
    @client ||= PublisherAtsApiClient.find_by(api_key: request.headers["X-Api-Key"])
  end

  def authenticate_client!
    return if client

    render status: :unauthorized,
           json: { errors: ["Invalid API key"] },
           content_type: "application/json"
  end

  def validate_create_payload
    raw_params = { vacancy: permitted_vacancy_params.to_h }
    create_validator = JsonSwaggerValidator.new("/ats-api/v1/vacancies", "post")
    unless create_validator.valid?(raw_params)
      render json: { errors: create_validator.errors(raw_params) }, status: :bad_request
    end
  end

  def validate_update_payload
    raw_params = { vacancy: permitted_vacancy_params.to_h }
    validator = JsonSwaggerValidator.new("/ats-api/v1/vacancies/{id}", "put")
    unless validator.valid?(raw_params)
      render json: { errors: validator.errors(raw_params) }, status: :bad_request
    end
  end

  def render_server_error(exception)
    Sentry.capture_exception(exception) # Sends the internal exception to Sentry, so it can be debugged/fixed.
    render json: { errors: ["There was an internal error processing this request"] }, status: :internal_server_error
  end

  def render_not_found
    render json: { errors: ["The given ID does not match any vacancy for your ATS"] }, status: :not_found
  end

  def render_bad_request(exception)
    render json: { errors: [exception.message] }, status: :bad_request
  end

  def render_unprocessable_entity(exception)
    render json: { errors: [exception.message] }, status: :unprocessable_entity
  end
end
