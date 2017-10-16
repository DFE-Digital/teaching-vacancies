class VacanciesController < ApplicationController
  def index
    @filters = VacancyFilters.new(params)
    @sort = VacancySort.new(default_column: 'expires_on', default_order: 'asc')
                       .update(column: sort_column, order: sort_order)
    @query = Vacancy.public_search(filters: @filters, sort: @sort)
    @vacancies = @query.page(params[:page]).records
  end

  def show
    @vacancy = Vacancy.published.friendly.find(params[:id])
  end

  private

  def sort_column
    params[:sort_column]
  end

  def sort_order
    params[:sort_order]
  end
end
