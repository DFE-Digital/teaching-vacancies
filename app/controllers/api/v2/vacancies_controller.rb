class Api::V2::VacanciesController < Api::ApplicationController
  def index
    @pagy, @vacancies = pagy(vacancies, items: 100)

    respond_to(&:json)
  end

  def create
    @vacancy = Vacancy.create!(vacancy_params)

    # logger.warn "Errors #{@vacancy.errors.messages}" if @vacancy.errors.any?

    respond_to(&:json)
  end

  def update
    @vacancy = vacancy

    respond_to(&:json)
  end

  def destroy; end

  def show
    @vacancy = vacancy
  end

  private

  KEY_MAPPINGS = {
    advertUrl: :external_advert_url,
    expiresAt: :expires_at,
    jobTitle: :job_title,
    jobAdvert: :skills_and_experience,
    salaryRange: :salary,
    # schoolUrns:
    jobRoles: :job_roles,
    workingPatterns: :working_patterns,
    contractType: :contract_type,
    phase: :phase,
  }.freeze

  def vacancy_params
    params.fetch(:vacancy)
          .permit(:advertUrl,
                  :expiresAt, :jobTitle, :jobAdvert, :salaryRange, :schoolUrns, :jobRoles, :workingPatterns, :contractType, :phase)
          .transform_keys { |key| KEY_MAPPINGS.fetch(key.to_sym) }.merge(organisations: [School.first])
  end

  def vacancy
    FactoryBot.build(:vacancy)
  end

  def vacancies
    Vacancy.includes(:organisations).live.order(publish_on: :desc)
  end
end
