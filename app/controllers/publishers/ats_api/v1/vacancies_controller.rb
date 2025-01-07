class Publishers::AtsApi::V1::VacanciesController < Api::ApplicationController
  before_action :authenticate_client!

  def index
    @pagy, @vacancies = pagy(vacancies.where(publisher_ats_api_client: client), items: 100)

    respond_to(&:json)
  end

  def show
    @vacancy = vacancy
  end

  def create
    begin
      @vacancy = Vacancy.new(vacancy_params)
    rescue ActionController::ParameterMissing
      render json: { error: "Request body could not be read properly" }, status: :bad_request
      return
    end

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
      render json: {
        errors: @vacancy.errors.full_messages.map { |msg| { error: msg } },
      }, status: :unprocessable_entity
    end
  end

  def update
    @vacancy = vacancy

    respond_to(&:json)
  end

  def destroy; end

  private

  def vacancy_params
    required_keys = %i[
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
    missing_keys = required_keys - params.fetch(:vacancy, {}).keys.map(&:to_sym)
    raise ActionController::ParameterMissing, "Missing required parameters: #{missing_keys.join(', ')}" if missing_keys.any?

    p = params.fetch(:vacancy).permit(:external_advert_url, :external_reference, :visa_sponsorship_available, :is_job_share,
                                      :expires_at, :job_title, :skills_and_experience, :is_parental_leave_cover, :salary, :job_advert, :contract_type,
                                      job_roles: [], working_patterns: [], phases: [], schools: [:trust_uid, { school_urns: [] }])

    organisations = if p[:schools][:trust_uid].present?
                      SchoolGroup.trusts.find_by(uid: p[:schools][:trust_uid]).schools.where(urn: p[:schools][:school_urns])
                    else
                      School.where(urn: p[:schools][:school_urns])
                    end

    raise ActiveRecord::RecordNotFound, "No valid organisations found" if organisations.blank?

    p[:publish_on] ||= Time.zone.today.to_s
    p[:working_patterns] ||= []
    p[:phases] ||= []

    p.except(:schools, :trust_uid).merge(organisations: organisations)
  end

  def vacancy
    FactoryBot.build(:vacancy, :external)
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
end
