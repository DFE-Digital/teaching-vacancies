class VacanciesController < ApplicationController
  include ParameterSanitiser

  DEFAULT_RADIUS = 20

  helper_method :location,
                :subject,
                :job_title,
                :minimum_salary,
                :working_pattern,
                :phase,
                :newly_qualified_teacher,
                :radius,
                :sort_column,
                :sort_order

  def index
    @filters = VacancyFilters.new(search_params)
    @sort = VacancySort.new.update(column: sort_column, order: sort_order)
    @vacancies = VacanciesFinder.new(@filters, @sort, page_number).vacancies

    expires_in 5.minutes, public: true
  end

  def show
    begin
      vacancy = Vacancy.listed.friendly.find(id)
    rescue ActiveRecord::RecordNotFound
      raise unless Vacancy.trashed.friendly.exists?(id)

      return render '/errors/trashed_vacancy_found', status: :not_found
    end

    return redirect_to(job_path(vacancy), status: :moved_permanently) if old_vacancy_path?(vacancy)

    @vacancy = VacancyPresenter.new(vacancy)

    VacancyPageView.new(vacancy).track unless authenticated?

    expires_in 5.minutes, public: true
  end

  def params
    @params ||= ParameterSanitiser.call(super)
  end

  private

  def search_params
    params.permit(*VacancyFilters::AVAILABLE_FILTERS).to_hash
  end

  def old_vacancy_path?(vacancy)
    request.path != job_path(vacancy) && !request.format.json?
  end

  def id
    params[:id]
  end

  def page_number
    return Vacancy.page.total_pages if Vacancy.page(params[:page]).out_of_range?

    params[:page]
  end

  def location
    params[:location]
  end

  def subject
    params[:subject]
  end

  def job_title
    params[:job_title]
  end

  def minimum_salary
    params[:minimum_salary]
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
    params[:radius] || DEFAULT_RADIUS
  end

  def sort_column
    params[:sort_column]
  end

  def sort_order
    params[:sort_order]
  end

  def set_headers
    response.set_header('X-Robots-Tag', 'noarchive')
  end
end
