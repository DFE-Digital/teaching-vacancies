class SupportUsers::ServiceData::VacanciesController < SupportUsers::ServiceData::BaseController
  def index
    @vacancies = Vacancy.all.order(created_at: :desc)
  end

  def show
    vacancy = Vacancy.friendly.find(params[:id])
    @vacancy = VacancyPresenter.new(vacancy)
  end
end
