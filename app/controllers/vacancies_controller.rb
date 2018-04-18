class VacanciesController < ApplicationController
  helper_method :sort_order, :sort_column

  def index
    @filters = VacancyFilters.new(sanitised_params)
    @sort = VacancySort.new(default_column: 'expires_on', default_order: 'asc')
                       .update(column: sort_column, order: sort_order)
    records = Vacancy.public_search(filters: @filters, sort: @sort).records
    @vacancies = VacanciesPresenter.new(records.page(params[:page]))
  end

  def show
    vacancy = Vacancy.published.friendly.find(id)
    @vacancy = VacancyPresenter.new(vacancy)
  end

  private def id
    params[:id]
  end

  private def page
    params[:page]
  end

  private def sort_column
    params[:sort_column]
  end

  private def sort_order
    params[:sort_order]
  end
end
