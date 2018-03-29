class HiringStaff::Vacancies::JobSpecificationController < HiringStaff::Vacancies::ApplicationController
  def new
    @job_specification_form = JobSpecificationForm.new(school_id: school.id)
    return if session[:current_step].blank?

    @job_specification_form = JobSpecificationForm.new(session[:vacancy_attributes])
    @job_specification_form.valid?
  end

  # rubocop:disable Metrics/AbcSize
  def create
    @job_specification_form = JobSpecificationForm.new(job_specification_form)
    store_vacancy_attributes(@job_specification_form.vacancy.attributes.compact!)

    if @job_specification_form.valid?
      vacancy = session_vacancy_id ? update_vacancy(job_specification_form) : save_vacancy_without_validation
      store_vacancy_attributes(@job_specification_form.vacancy.attributes.compact!)

      redirect_to_next_step(vacancy)
    else
      session[:current_step] = :step_1 if session[:current_step].blank?
      redirect_to job_specification_school_vacancy_path(school)
    end
  end
  # rubocop:enable Metrics/AbcSize

  def edit
    vacancy = school.vacancies.published.find(vacancy_id)

    @job_specification_form = JobSpecificationForm.new(vacancy.attributes)
    @job_specification_form.valid?
  end

  def update
    vacancy = school.vacancies.published.find(vacancy_id)
    @job_specification_form = JobSpecificationForm.new(job_specification_form)
    @job_specification_form.id = vacancy.id

    if @job_specification_form.valid?
      vacancy.update_attributes(@job_specification_form.vacancy.attributes.compact)
      redirect_to edit_school_vacancy_path(school, vacancy.id), notice: 'The vacancy has been updated'
    else
      render 'edit'
    end
  end

  private

  def job_specification_form
    params.require(:job_specification_form).permit(:job_title, :job_description, :headline,
                                                   :minimum_salary, :maximum_salary, :working_pattern,
                                                   :school_id, :subject_id, :pay_scale_id, :leadership_id,
                                                   :starts_on_dd, :starts_on_mm, :starts_on_yyyy,
                                                   :ends_on_dd, :ends_on_mm, :ends_on_yyyy)
  end

  def save_vacancy_without_validation
    @job_specification_form.vacancy.school_id = school.id
    @job_specification_form.vacancy.send :set_slug
    @job_specification_form.vacancy.status = :draft
    @job_specification_form.vacancy.save(validate: false)
    @job_specification_form.vacancy
  end

  def next_step
    candidate_specification_school_vacancy_path(school_id: school.id)
  end
end
