class VacanciesController < ApplicationController
  helper_method :location,
                :keyword,
                :minimum_salary,
                :maximum_salary,
                :working_pattern,
                :phase,
                :newly_qualified_teacher,
                :radius,
                :sort_column,
                :sort_order

  def index
    @filters = VacancyFilters.new(search_params)
    @sort = VacancySort.new.update(column: sort_column, order: sort_order)

    records = Vacancy.public_search(filters: @filters, sort: @sort).page(params[:page]).records

    @vacancies = VacanciesPresenter.new(records, searched: searched?)
  end

  def show
    vacancy = Vacancy.listed.friendly.find(id)
    return redirect_to(job_path(vacancy), status: :moved_permanently) if old_vacancy_path?(vacancy)
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
    params.permit(:keyword, :location, :radius,
                  :minimum_salary, :maximum_salary, :phase,
                  :phase, :working_pattern, :newly_qualified_teacher).to_hash
  end

  def old_vacancy_path?(vacancy)
    request.path != job_path(vacancy) && !request.format.json?
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

  def newly_qualified_teacher
    params[:newly_qualified_teacher]
  end

  def radius
    params[:radius]
  end

  def sort_column
    params[:sort_column]
  end

  def sort_order
    params[:sort_order]
  end

  def searched?
    params[:commit]&.eql?(I18n.t('buttons.apply_filters')) ||
      params[:commit]&.eql?(I18n.t('buttons.apply_filters_if_criteria'))
  end

  def set_headers
    response.set_header('X-Robots-Tag', 'noarchive')
  end
end
