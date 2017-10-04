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
  def new
    @publish_vacancy_form = publish_vacancy_form
    @current_stage = params[:stage] ? params[:stage].to_sym : @publish_vacancy_form.default_stage
    not_found unless @publish_vacancy_form.stages.keys.include?(@current_stage)
    @vacancy = Vacancy.new
  end

  private

  def publish_vacancy_form
    PublishVacancyForm.new(
      job_specification:        JobSpecificationForm,
      candidate_specification:  CandidateSpecificationForm,
      vacancy_specification:    VacancySpecificationForm,
    )
  end


  def sort_column
    params[:sort_column]
  end

  def sort_order
    params[:sort_order]
  end
end
