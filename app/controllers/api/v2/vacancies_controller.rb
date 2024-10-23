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

  def vacancy_params
    params.fetch(:vacancy)
          .permit(:external_advert_url, :external_reference, :visa_sponsorship_available, :is_job_share,
                  :expires_at, :job_title, :skills_and_experience, :is_parental_leave_cover, :salary,
                  :job_roles, :working_patterns, :contract_type, :phases)
          .merge(organisations: [School.first])
  end

  def vacancy
    FactoryBot.build(:vacancy)
  end

  def vacancies
    Vacancy.includes(:organisations).live.order(publish_on: :desc)
  end
end
