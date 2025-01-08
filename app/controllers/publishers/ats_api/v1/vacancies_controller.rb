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
    @vacancy = Vacancy.new(create_vacancy_params)

    if Vacancy.exists?(external_reference: @vacancy.external_reference)
      existing_vacancy = Vacancy.find_by(external_reference: @vacancy.external_reference)
      headers["Link"] = "<#{vacancy_url(existing_vacancy)}>; rel=\"existing\""
      render json: {
        error: "A vacancy with the provided external reference already exists",
      }, status: :conflict
      return
    end

    if @vacancy.save
      render json: { id: @vacancy.id }, status: :created
    else
      render_validation_errors(@vacancy)
    end
  end

  def update
    @vacancy = vacancy

    respond_to(&:json)
  end

  def destroy; end

  private

  def required_create_vacancy_keys
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
    missing_keys = required_create_vacancy_keys - params.fetch(:vacancy, {}).keys.map(&:to_sym)
    raise ActionController::ParameterMissing, "Missing required parameters: #{missing_keys.join(', ')}" if missing_keys.any?

    params.fetch(:vacancy).permit(:external_advert_url, :external_reference, :visa_sponsorship_available, :is_job_share,
                                      :expires_at, :job_title, :skills_and_experience, :is_parental_leave_cover, :salary, :job_advert, :contract_type,
                                      job_roles: [], working_patterns: [], phases: [], schools: [:trust_uid, { school_urns: [] }])
  end

  def create_vacancy_params
    organisations = fetch_organisations(permitted_vacancy_params[:schools])
    raise ActiveRecord::RecordNotFound, "No valid organisations found" if organisations.blank?

    permitted_vacancy_params[:publish_on] ||= Time.zone.today.to_s
    permitted_vacancy_params[:working_patterns] ||= []
    permitted_vacancy_params[:phases] ||= []

    permitted_vacancy_params.except(:schools, :trust_uid).merge(organisations: organisations)
  end

  def fetch_organisations(school_params)
    return [] unless school_params

    if school_params[:trust_uid].present?
      SchoolGroup.trusts.find_by(uid: school_params[:trust_uid]).schools.where(urn: school_params[:school_urns])
    else
      School.where(urn: school_params[:school_urns])
    end
  end

  def render_validation_errors(vacancy)
    render json: {
      errors: vacancy.errors.full_messages.map { |msg| { error: msg } },
    }, status: :unprocessable_entity
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
