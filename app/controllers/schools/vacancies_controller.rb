class Schools::VacanciesController < ApplicationController
  before_action :set_school

  def new
    redirect_to step_1_school_vacancies_path(school_id: @school.id)
  end

  def step_1
    if session[:vacancy_attributes]
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
    if @job_specification_form.valid?
      redirect_to step_2_school_vacancies_path(school_id: @school.id)
    else
      redirect_to step_1_school_vacancies_path(school_id: @school.id)
    end
  end

  def step_2
    @candidate_specification_form = ::CandidateSpecificationForm.new(session[:vacancy_attributes])
    @candidate_specification_form.valid?
  end

  def submit_step_2
    @candidate_specification_form = CandidateSpecificationForm.new(candidate_specification_form)
    session[:vacancy_attributes].merge!(@candidate_specification_form.vacancy.attributes.compact!)
    if @candidate_specification_form.valid?
      redirect_to step_3_school_vacancies_path(school_id: @school.id)
    else
      redirect_to step_2_school_vacancies_path(school_id: @school.id)
    end
  end

  def step_3
    @application_details_form = ::ApplicationDetailsForm.new(session[:vacancy_attributes])
    @application_details_form.valid?
  end

  def submit_step_3
    @candidate_specification_form = ApplicationDetailsForm.new(application_details_form)
    session[:vacancy_attributes].merge!(@candidate_specification_form.vacancy.attributes.compact!)
    if @candidate_specification_form.valid?
      redirect_to step_3_school_vacancies_path(school_id: @school.id)
    else
      redirect_to step_2_school_vacancies_path(school_id: @school.id)
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
    params.require(:application_details_form).permit(:contact_email, :publish_on, :expires_on)
  end

  def vacancy_id
    params.permit![:vacancy_id]
  end
end
