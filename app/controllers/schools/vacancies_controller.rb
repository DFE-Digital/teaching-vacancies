class Schools::VacanciesController < Schools::BaseController
  def show
    @school = School.find(school_id)
    vacancy = Vacancy.friendly.find(params[:id])
    @vacancy = VacancyPresenter.new(vacancy)
  end

  def new
    @school = School.find(school_id)
    @vacancy = @school.vacancies.new

    render :job_specification
  end

  def create
    @school = School.find(school_id)

    @vacancy = @school.vacancies.new(vacancy_params)
    @vacancy.status = :draft
    if @vacancy.save
      redirect_to school_vacancy_candidate_specification_path(@school.id, @vacancy.slug)
    else
      render :job_specification
    end
  end

  def school_id
    params.require(:school_id)
  end

  def job_specification
    @school = School.find(school_id)
    @vacancy = Vacancy.find_by!(slug: params[:vacancy_id])
  end

  def candidate_specification
    @school = School.find(school_id)
    @vacancy = Vacancy.find_by!(slug: params[:vacancy_id])
  end

  def application_details
    @school = School.find(school_id)
    @vacancy = Vacancy.find_by!(slug: params[:vacancy_id])
  end

  def update
    @school = School.find(school_id)
    @vacancy = Vacancy.find_by!(slug: params[:id])

    if @vacancy.update_attributes(vacancy_params)
      redirect_to next_path(params[:next])
    else
      render view_for_from(params[:from])
    end
  end

  def publish
    @school = School.find(school_id)
    vacancy = Vacancy.friendly.find(params[:id])

    if PublishVacancy.new(vacancy: vacancy).call
      redirect_to published_school_vacancy_path(@school.id, vacancy.slug)
    else
      redirect_to review_school_vacancy_path(@school.id, vacancy.slug), notice: 'Unable to publish vacancy. Try again!'
    end
  end

  def published
    @school = School.find(school_id)
    vacancy = Vacancy.friendly.find(params[:id])
    @vacancy = VacancyPresenter.new(vacancy)
  end

  def edit
    @vacancy = Vacancy.friendly.find(params[:id])
  end

  def review
    @school = School.find(school_id)
    vacancy = Vacancy.friendly.find(params[:id])
    if vacancy.published?
      redirect_to school_vacancy_path(@school.id, vacancy), notice: 'This vacancy has already been published'
    end

    @vacancy = VacancyPresenter.new(vacancy)
  end

  private

  def view_for_from(from_param)
    case from_param
    when 'job_specification'
      :job_specification
    when 'candidate_specification'
      :candidate_specification
    when 'application_details'
      :application_details
    else
      raise 'Unsure where to redirect to...'
    end
  end

  def next_path(next_param)
    @school = School.find(school_id)
    case next_param
    when 'candidate_specification'
      school_vacancy_candidate_specification_path(@school.id, @vacancy)
    when 'application_details'
      school_vacancy_application_details_path(@school.id, @vacancy)
    else
      review_school_vacancy_path(@school.id, @vacancy)
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
