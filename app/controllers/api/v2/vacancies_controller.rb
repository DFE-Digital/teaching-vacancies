class Api::V2::VacanciesController < Api::ApplicationController
  def index
    @pagy, @vacancies = pagy(vacancies, items: 100)

    respond_to(&:json)
  end

  def show
    @vacancy = vacancy
  end

  # No idea why rubocop can't see the check after the create call
  # rubocop:disable Rails/SaveBang
  def create
    @vacancy = Vacancy.create(vacancy_params)

    respond_to do |format|
      format.json do
        if @vacancy.persisted?
          render status: :created
        else
          render status: :bad_request
        end
      end
    end
  end
  # rubocop:enable Rails/SaveBang

  def update
    @vacancy = vacancy

    respond_to(&:json)
  end

  def destroy; end

  private

  def vacancy_params
    p = params.fetch(:vacancy).permit(:external_advert_url, :external_reference, :visa_sponsorship_available, :is_job_share,
                                      :expires_at, :job_title, :skills_and_experience, :is_parental_leave_cover, :salary,
                                      :job_roles, :working_patterns, :contract_type, :phases, school_urns: [])

    p.except(:school_urns)
          .merge(organisations: p.fetch(:school_urns, []).map { School.find_by(urn: _1) }.compact)
  end

  def vacancy
    FactoryBot.build(:vacancy, :external)
  end

  def vacancies
    Vacancy.includes(:organisations).live.order(publish_on: :desc)
  end
end