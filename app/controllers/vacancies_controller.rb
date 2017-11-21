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
    @school = School.find(params[:school_id])
    @vacancy = @school.vacancies.new
    render :job_specification
  end

  def create
    @school = School.find(params[:vacancy][:school_id])

    @vacancy = @school.vacancies.new(vacancy_params)
    @vacancy.status = :draft
    if @vacancy.save
      redirect_to vacancy_candidate_specification_path(@vacancy)
    else
      render :job_specification
    end
  end

  def job_specification
    @vacancy = Vacancy.find_by!(slug: params[:vacancy_id])
  end

  def candidate_specification
    @vacancy = Vacancy.find_by!(slug: params[:vacancy_id])
  end

  def application_details
    @vacancy = Vacancy.find_by!(slug: params[:vacancy_id])
  end

  def update
    @vacancy = Vacancy.find_by!(slug: params[:id])

    if @vacancy.update_attributes(vacancy_params)
      redirect_to next_path(params[:next])
    else
      render view_for_from(params[:from])
    end
  end

  def publish
    vacancy = Vacancy.friendly.find(params[:id])
    if PublishVacancy.new(vacancy: vacancy).call
      redirect_to published_vacancy_path(vacancy)
    else
      redirect_to review_vacancy_path(vacancy), notice: 'Unable to publish vacancy. Try again!'
    end
  end

  def published
    vacancy = Vacancy.published.friendly.find(params[:id])
    @vacancy = VacancyPresenter.new(vacancy)
  end

  def edit
    @vacancy = Vacancy.friendly.find(params[:id])
  end

  def review
    vacancy = Vacancy.friendly.find(params[:id])
    redirect_to vacancy_path(vacancy), notice: 'This vacancy has already been published' if vacancy.published?

    @vacancy = VacancyPresenter.new(vacancy)
  end

  private

  def view_for_from(from_param)
    case from_param
    when 'job_specification'
      :new
    when 'candidate_specification'
      :candidate_specification
    when 'application_details'
      :application_details
    else
      raise 'Unsure where to redirect to...'
    end
  end

  def next_path(next_param)
    case next_param
    when 'candidate_specification'
      vacancy_candidate_specification_path(@vacancy)
    when 'application_details'
      vacancy_application_details_path(@vacancy)
    else
      review_vacancy_path(@vacancy)
    end
  end

  def vacancy_params
    params.require(:vacancy).permit(job_spec_params +
                                    candidate_params +
                                    vacancy_detail_params)
  end

  def job_spec_params
    %i[job_title headline job_description
       benefits subject minimum_salary
       maximum_salary pay_scale_id working_pattern
       weekly_hours leadership starts_on_dd starts_on_mm starts_on_yyyy
       ends_on_dd ends_on_mm ends_on_yyyy]
  end

  def candidate_params
    %i[essential_requirements education qualifications experience]
  end

  def vacancy_detail_params
    %i[contact_email expires_on_mm expires_on_dd expires_on_yyyy publish_on_mm publish_on_dd publish_on_yyyy]
  end

  def sort_column
    params[:sort_column]
  end

  def sort_order
    params[:sort_order]
  end
end
