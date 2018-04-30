class VacanciesController < ApplicationController
  helper_method :location,
                :keyword,
                :minimum_salary,
                :maximum_salary,
                :working_pattern,
                :phase,
                :sort_column,
                :sort_order

  def index
    @filters = VacancyFilters.new(search_params)
    @sort = VacancySort.new(default_column: 'expires_on', default_order: 'asc')
                       .update(column: sort_column, order: sort_order)
    records = Vacancy.public_search(filters: @filters, sort: @sort).page(params[:page]).records
    @vacancies = VacanciesPresenter.new(records)
  end

  def show
    vacancy = Vacancy.published.friendly.find(id)
    @vacancy = VacancyPresenter.new(vacancy)
  end

  def params
    sanitised_params = super.each_pair do |key, value|
      super[key] = Sanitize.fragment(value)
    end
    ActionController::Parameters.new(sanitised_params)
  end

  private

  def search_params
    params.permit(:keyword, :location, :minimum_salary, :maximum_salary, :phase, :working_pattern).to_hash
  end

  def id
    params[:id]
  end

  def page
    params[:page]
  end

  def location
    params[:location]
  end

  def keyword
    params[:keyword]
  end

  def minimum_salary
    params[:minimum_salary]
  end

  def maximum_salary
    params[:maximum_salary]
  end

  def working_pattern
    params[:working_pattern]
  end

  def phase
    params[:phase]
  end

  def sort_column
    params[:sort_column]
  end

  def sort_order
    params[:sort_order]
  end
end
