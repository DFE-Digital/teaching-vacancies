class Schools::VacanciesController < ApplicationController
  before_action :set_school

  def new
    redirect_to job_specification_school_vacancy_path(school_id: @school.id)
  end

  def step_3
    redirect_to job_specification_school_vacancy_path(school_id: @school.id) unless session_vacancy_id

    @application_details_form = ApplicationDetailsForm.new(session[:vacancy_attributes])
    @application_details_form.valid? if session[:current_step].eql?('step_3')
  end

  def submit_step_3
    redirect_to job_specification_school_vacancy_path(school_id: @school.id) unless session_vacancy_id

    @application_details_form = ApplicationDetailsForm.new(application_details_form)
    store_vacancy_attributes(@application_details_form.vacancy.attributes.compact!)

    if @application_details_form.valid?
      vacancy = update_vacancy(application_details_form)

      session[:current_step] = :review
      redirect_to school_vacancy_review_path(school_id: @school.id, vacancy_id: vacancy.id)
    else
      session[:current_step] = :step_3
      redirect_to step_3_school_vacancies_path(school_id: @school.id)
    end
  end

  def review
    vacancy  = Vacancy.find(vacancy_id)
    @vacancy = VacancyPresenter.new(vacancy)
  end

  def publish
    vacancy = Vacancy.find(vacancy_id)
    if PublishVacancy.new(vacancy: vacancy).call
      session[:vacancy_attributes] = nil
      redirect_to vacancy_path(vacancy), notice: 'The vacancy is now available'
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

  def store_vacancy_attributes(vacancy_attributes)
    session[:vacancy_attributes] ||= {}
    session[:vacancy_attributes].merge!(vacancy_attributes)
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
    session[:vacancy_attributes].present? ? session[:vacancy_attributes]['id'] : false
  end

  def update_vacancy(attributes)
    vacancy = @school.vacancies.find(session_vacancy_id)
    vacancy.update_attributes(attributes)
    vacancy
  end
end
