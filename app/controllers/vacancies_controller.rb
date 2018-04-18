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

  helper_method :location
  private def location
    params[:location]
  end

  helper_method :keyword
  private def keyword
    params[:keyword]
  end

  helper_method :minimum_salary
  private def minimum_salary
    params[:minimum_salary]
  end

  helper_method :maximum_salary
  private def maximum_salary
    params[:maximum_salary]
  end

  helper_method :working_pattern
  private def working_pattern
    params[:working_pattern]
  end

  helper_method :phase
  private def phase
    params[:phase]
  end

  helper_method :sort_column
  private def sort_column
    params[:sort_column]
  end

  helper_method :sort_order
  private def sort_order
    params[:sort_order]
  end

end
