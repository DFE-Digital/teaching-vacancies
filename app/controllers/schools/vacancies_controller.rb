class Schools::VacanciesController < ApplicationController
  before_action :set_school

  def new
    redirect_to step_1_school_vacancies_path(school_id: @school.id)
  end

  def step_1
    if session[:vacancy_id].present?
      vacancy = Vacancy.find(vacancy_id)
      @job_specification_form = JobSpecificationForm.new(vacancy.attributes)
    elsif session[:vacancy_attributes]
      @job_specification_form = JobSpecificationForm.new(session[:vacancy_attributes])
      @job_specification_form.school_id = @school.id
      @job_specification_form.valid?
    else
      @job_specification_form = JobSpecificationForm.new(school_id: @school.id)
    end
  end

  def submit_step_1
    @job_specification_form = JobSpecificationForm.new(job_spec_params)

    session[:vacancy_attributes] ||= {}
    session[:vacancy_attributes].merge!(@job_specification_form.vacancy.attributes)
    @job_specification_form.vacancy.send :set_slug
    if @job_specification_form.valid?
      @job_specification_form.vacancy.save(validate: false)
      session[:vacancy_attributes][:id] = @job_specification_form.vacancy.id
      redirect_to step_2_school_vacancies_path(school_id: @school.id)
    else
      session[:current_step] = :step_1
      redirect_to step_1_school_vacancies_path(school_id: @school.id)
    end
  end

  def step_2
    if session_vacancy_id.present? and session[:vacancy_attributes].present?
      vacancy = Vacancy.find(session_vacancy_id)
      @candidate_specification_form = ::CandidateSpecificationForm.new(session[:vacancy_attributes])
      @candidate_specification_form.valid? if session[:current_step].eql?('step_2')
    else
      redirect_to step_1_school_vacancies_path(school_id: @school.id)
    end
  end

  def submit_step_2
    @candidate_specification_form = CandidateSpecificationForm.new(candidate_specification_form)

    if session_vacancy_id.present?
      vacancy = @school.vacancies.find(session_vacancy_id)
      session[:vacancy_attributes].merge!(@candidate_specification_form.vacancy.attributes.compact!)

      if @candidate_specification_form.valid?
        vacancy.update_attributes(candidate_specification_form)
        redirect_to step_3_school_vacancies_path(school_id: @school.id)
      else
        session[:current_step] = :step_2
        redirect_to step_2_school_vacancies_path(school_id: @school.id)
      end
    end
  end

  def step_3
    if session_vacancy_id.present? and session[:vacancy_attributes].present?
      vacancy = Vacancy.find(session_vacancy_id)
      @application_details_form = ::ApplicationDetailsForm.new(session[:vacancy_attributes])
      @application_details_form.valid? if session[:current_step].eql?('step_3')
    else
      redirect_to new_school_vacancies_path(school_id: @school.id)
    end
  end

  def submit_step_3
    @application_details_form = ApplicationDetailsForm.new(application_details_form)

    if session_vacancy_id.present?
      vacancy = @school.vacancies.find(session_vacancy_id)
      session[:vacancy_attributes].merge!(@application_details_form.vacancy.attributes.compact!)

      if @application_details_form.valid?
        vacancy.update_attributes(application_details_form)
        session[:current_step] = :review
        redirect_to school_vacancy_review_path(school_id: @school.id, vacancy_id: vacancy.id)
      else
        session[:current_step] = :step_3
        redirect_to step_3_school_vacancies_path(school_id: @school.id)
      end
    end
  end

  def review
    vacancy  = Vacancy.find(vacancy_id)
    @vacancy = VacancyPresenter.new(vacancy)
  end

  def publish
    vacancy = Vacancy.find(vacancy_id)
    if PublishVacancy.new(vacancy: vacancy).call
      redirect_to vacancy_path(vacancy), notice: "The vacancy is now available"
    else
      redirect_to review_school_vacancy_path(school_id: @school.id, vacancy_id: vacancy.id),
        notice: 'We were unable to publish your vacancy. Please try again.'
    end
  end

  private

  def set_school
    @school = School.find_by(id: school_id)
  end

  def school_id
    params.permit![:school_id]
  end

  def job_spec_params
    params.require(:job_specification_form).permit!
  end

  def candidate_specification_form
    params.require(:candidate_specification_form).permit!
  end

  def application_details_form
    params.require(:application_details_form).permit(:contact_email,
                                                     :expires_on_dd, :expires_on_mm, :expires_on_yyyy,
                                                     :publish_on_dd, :publish_on_mm, :publish_on_yyyy)
  end

  def vacancy_id
    params.permit![:vacancy_id]
  end

  def session_vacancy_id
    session[:vacancy_attributes]['id']
  end
end
