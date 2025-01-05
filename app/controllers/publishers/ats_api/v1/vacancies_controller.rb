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
    @vacancy = Vacancy.new(vacancy_params)

    if @vacancy.save
      render status: :created
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
    p = params.fetch(:vacancy).permit(:external_advert_url, :external_reference, :visa_sponsorship_available, :is_job_share,
                                      :expires_at, :job_title, :skills_and_experience, :is_parental_leave_cover, :salary, :job_advert, :contract_type,
                                      job_roles: [], working_patterns: [], phases: [], school_urns: [], trust_uid: nil)

    organisations = if p[:trust_uid].present?
                      SchoolGroup.trusts.find_by(uid: p[:trust_uid]).schools.where(urn: p[:school_urns])
                    else
                      School.where(urn: p[:school_urns])
                    end

    raise ActiveRecord::RecordNotFound, "No valid organisations found" if organisations.blank?

    p[:publish_on] ||= Time.zone.today.to_s
    p[:working_patterns] ||= []
    p[:phases] ||= []

    p.except(:school_urns, :trust_uid).merge(organisations: organisations)
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
