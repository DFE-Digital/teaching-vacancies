class Publishers::AtsApi::V1::VacanciesController < Api::ApplicationController
  before_action :authenticate_client!

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActionController::ParameterMissing, with: :render_bad_request

  def index
    @pagy, @vacancies = pagy(vacancies.where(publisher_ats_api_client: client), items: 100)

    render json: {
      data: @vacancies.map { |vacancy| render_vacancy(vacancy) },
      meta: { totalPages: @pagy.pages, count: @pagy.page },
    }
  end

  def show
    vacancy = Vacancy.find(params[:id])
    render json: render_vacancy(vacancy)
  end

  def create
    result = Publishers::AtsApi::V1::CreateVacancyService.new(permitted_vacancy_params).call

    if result[:headers]
      headers.merge!(result[:headers])
    end

    render result.slice(:json, :status)
  end

  def update
    vacancy = Vacancy.find(params[:id])
    result = Publishers::AtsApi::V1::UpdateVacancyService.new(vacancy, permitted_vacancy_params).call

    render result.slice(:json, :status)
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
    missing_keys = required_vacancy_keys - params.fetch(:vacancy, {}).keys.map(&:to_sym)
    raise ActionController::ParameterMissing, "Missing required parameters: #{missing_keys.join(', ')}" if missing_keys.any?

    params.fetch(:vacancy).permit(:external_advert_url, :external_reference, :visa_sponsorship_available, :is_job_share,
                                  :expires_at, :job_title, :skills_and_experience, :is_parental_leave_cover, :salary, :job_advert, :contract_type,
                                  job_roles: [], working_patterns: [], phases: [], schools: [:trust_uid, { school_urns: [] }])
  end

  def vacancies
    Vacancy.live.includes(:organisations).order(publish_on: :desc)
  end

  def render_vacancy(vacancy)
    Publishers::AtsApi::V1::VacancySerialiser.new(vacancy: vacancy).call
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
end
