class Publishers::AtsApi::V1::VacanciesController < Api::ApplicationController
  before_action :authenticate_client!
  before_action :validate_payload, only: %i[create update]

  rescue_from StandardError, with: :render_server_error
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActionController::ParameterMissing, with: :render_bad_request
  rescue_from Publishers::AtsApi::OrganisationFetcher::InvalidOrganisationError, with: :render_unprocessable_entity

  def index
    @pagy, @vacancies = pagy(vacancies.where(publisher_ats_api_client: client), items: 100)

    respond_to(&:json)
  end

  def show
    @vacancy = Vacancy.find_by!(publisher_ats_api_client: client, id: params[:id])

    respond_to(&:json)
  end

  def create
    result = Publishers::AtsApi::CreateVacancyService.call(permitted_vacancy_params)

    render result.slice(:json, :status)
  end

  def update
    vacancy = Vacancy.find_by!(publisher_ats_api_client: client, id: params[:id])

    result = Publishers::AtsApi::UpdateVacancyService.call(vacancy, permitted_vacancy_params)

    if result[:status] == :ok
      @vacancy = vacancy
      render :show
    else
      render result.slice(:json, :status)
    end
  end

  def destroy
    vacancy = Vacancy.find_by!(publisher_ats_api_client: client, id: params[:id])
    vacancy.destroy!

    head :no_content
  end

  private

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
                  schools: [:trust_uid, { school_urns: [] }])
          .merge(publisher_ats_api_client_id: client.id)
  end
  # rubocop:enable Metrics/MethodLength

  def vacancies
    Vacancy.live.includes(:organisations).order(publish_on: :desc)
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

  def validate_payload
    missing_keys = required_vacancy_keys - params.fetch(:vacancy, {}).keys.map(&:to_sym)
    raise ActionController::ParameterMissing, missing_keys.join(", ") if missing_keys.any?
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
