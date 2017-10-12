class VacanciesController < ApplicationController
  def index

    @filters = VacancyFilters.new(params)
    @sort = VacancySort.new(default_column: 'expires_on', default_order: 'asc')
                       .update(column: sort_column, order: sort_order)
    @query = Vacancy.public_search(filters: @filters, sort: @sort)
    vacancies = @query.page(params[:page]).records

    @vacancies = VacanciesPresenter.new(vacancies)
  end

  def show
    vacancy = Vacancy.published.friendly.find(params[:id])
    @vacancy = VacancyPresenter.new(vacancy)
  end
  def new
    @vacancy = Vacancy.new
  end

  def create
    @vacancy = CreateVacancy.new(School.first).call(vacancy_params)
    if @vacancy.valid?
      redirect_to review_vacancy_path(@vacancy)
    else
      render :new
    end
  end

  def publish
    vacancy = Vacancy.friendly.find(params[:id])
    vacancy.update_attribute(:status, :published)

    @vacancy = VacancyPresenter.new(vacancy)
  end

  def edit
    @vacancy = Vacancy.friendly.find(params[:id])
  end

  def review
    vacancy = Vacancy.friendly.find(params[:id])
    @vacancy = VacancyPresenter.new(vacancy)
  end

  private

  def vacancy_params
    params.require(:vacancy).permit(:job_title, :headline, :job_description,
                                    :starts_on, :ends_on, :weekly_hours,
                                    :pay_scale_id, :leadership_id, :subject_id,
                                    :benefits, :essential_requirements, :education,
                                    :qualifications, :publish_on, :working_pattern,
                                    :expires_on, :minimum_salary, :maximum_salary)
  end


  def sort_column
    params[:sort_column]
  end

  def sort_order
    params[:sort_order]
  end
end
