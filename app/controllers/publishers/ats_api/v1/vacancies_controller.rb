class Publishers::AtsApi::V1::VacanciesController < Api::ApplicationController
  skip_before_action :verify_authenticity_token # API requests don't need CRSF protection.

  before_action :authenticate_client!
  before_action :validate_create_payload, only: %i[create]
  before_action :validate_update_payload, only: %i[update]
  before_action :set_vacancy, only: %i[show update destroy]

  rescue_from StandardError, with: :render_server_error
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from Publishers::AtsApi::OrganisationFetcher::InvalidOrganisationError, with: :render_unprocessable_entity
  # If there is an issue with the parameter parsing we return a controlled 400 error with a messagge rather than a default 500 error.
  rescue_from ActionController::ParameterMissing, with: :render_bad_request

  def index
    @pagy, @vacancies = pagy(vacancies, limit: 100, page: params[:page] || 1)
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
      UpdateGoogleIndexQueueJob.perform_later(job_url(@vacancy)) if @vacancy.live?
      render :show
    else
      render result.slice(:json, :status)
    end
  end

  def destroy
    @vacancy.trash!
    # google index is removed by .trash!
    head :no_content
  end

  private

  def set_vacancy
    @vacancy = PublishedVacancy.kept.find_by!(publisher_ats_api_client: client, id: params[:id])
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
    params.fetch(:vacancy, {})
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
    PublishedVacancy
      .includes(:organisations)
      .kept
      .order(publish_on: :desc)
      .where(publisher_ats_api_client: client)
  end

  def client
    return @client if defined?(@client)

    @client = PublisherAtsApiClient.find_by(api_key: request.headers["X-Api-Key"])
  end

  def authenticate_client!
    return if client

    render status: :unauthorized,
           json: { errors: ["Invalid API key"] },
           content_type: "application/json"
  end

  # To ensure that the Json Swagger validator will raise the appropriate error when the params are not wrapped in a
  # 'vacancy' key, we will only wrap the attributes within the 'vacancy' key if it was provided like that.
  # If not, we will pass an empty hash to the validator, that will complain that the 'vacancy' key is missing while using
  # the same error code and format as the other Json Swagger validator errors.
  def payload_for_validation
    if params.key?(:vacancy)
      { vacancy: permitted_vacancy_params.to_h }
    else
      {}
    end
  end

  def validate_create_payload
    validator = JsonSwaggerValidator.new("/ats-api/v1/vacancies", "post")
    unless validator.valid?(payload_for_validation)
      render json: { errors: validator.errors(payload_for_validation) }, status: :bad_request
    end
  end

  def validate_update_payload
    validator = JsonSwaggerValidator.new("/ats-api/v1/vacancies/{id}", "put")
    unless validator.valid?(payload_for_validation)
      render json: { errors: validator.errors(payload_for_validation) }, status: :bad_request
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
