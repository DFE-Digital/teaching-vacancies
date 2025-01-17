class Publishers::AtsApi::V1::VacanciesController < Api::ApplicationController
  before_action :authenticate_client!
  before_action :validate_payload, only: %i[create update]

  rescue_from StandardError, with: :render_server_error
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActionController::ParameterMissing, with: :render_bad_request
  rescue_from Publishers::AtsApi::CreateVacancyService::InvalidOrganisationError, with: :render_bad_request

  def index
    @pagy, @vacancies = pagy(vacancies.where(publisher_ats_api_client: client), items: 100)

    respond_to(&:json)
  end

  def show
    @vacancy = Vacancy.find(params[:id])

    respond_to(&:json)
  end

  def create
    result = Publishers::AtsApi::CreateVacancyService.call(permitted_vacancy_params)

    render result.slice(:json, :status)
  end

  def update
    vacancy = Vacancy.find(params[:id])
    result = Publishers::AtsApi::UpdateVacancyService.call(vacancy, permitted_vacancy_params)

    if result[:success]
      @vacancy = vacancy
      render :show
    else
      render json: { errors: result[:errors] }, status: :unprocessable_entity
    end
  end

  def destroy
    vacancy = Vacancy.find(params[:id])
    vacancy.destroy!

    head :no_content
  end

  private

  def required_vacancy_keys
    %i[
      external_advert_url
      expires_at
      job_title
      skills_and_experience
      salary
      visa_sponsorship_available
      external_reference
      is_job_share
      job_roles
      working_patterns
      contract_type
      phases
      schools
    ]
  end

  def permitted_vacancy_params
    params.fetch(:vacancy)
          .permit(:external_advert_url, :external_reference, :visa_sponsorship_available, :is_job_share,
                  :expires_at, :job_title, :skills_and_experience, :is_parental_leave_cover, :salary, :job_advert, :contract_type,
                  job_roles: [], working_patterns: [], phases: [], schools: [:trust_uid, { school_urns: [] }])
          .merge(publisher_ats_api_client_id: client.id)
  end

  def vacancies
    Vacancy.live.includes(:organisations).order(publish_on: :desc)
  end

  def client
    @client ||= PublisherAtsApiClient.find_by(api_key: request.headers["X-Api-Key"])
  end

  def authenticate_client!
    return if client

    render status: :unauthorized,
           json: { error: "Invalid API key" },
           content_type: "application/json"
  end

  def validate_payload
    missing_keys = required_vacancy_keys - params.fetch(:vacancy, {}).keys.map(&:to_sym)
    raise ActionController::ParameterMissing, "Missing required parameters: #{missing_keys.join(', ')}" if missing_keys.any?
  end

  def render_server_error(exception)
    render json: { error: "Internal server error", message: exception.message }, status: :internal_server_error
  end

  def render_not_found
    render json: { error: "The given ID does not match any vacancy for your ATS" }, status: :not_found
  end

  def render_bad_request(exception = nil)
    render json: { error: exception&.message.presence || "Request body could not be read properly" }, status: :bad_request
  end
end
