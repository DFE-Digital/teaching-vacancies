class Schools::VacanciesController < ApplicationController
  before_action :set_school

  def new
    redirect_to step_1_school_vacancies_path(school_id: @school.id)
  end

  def step_1
    @job_specification_form = JobSpecificationForm.new(school_id: @school.id)
  end

  def submit_step_1
    @job_specification_form = JobSpecificationForm.new(job_spec_params)
    if @job_specification_form.valid?
      @job_specification_form.save
      redirect_to step_2_school_vacancies_path(school_id: @school.id, vacancy_id: @job_specification_form.id)
    else
      render 'step_1'
    end
  end

  def step_2
    @vacancy = Vacancy.find(vacancy_id)
    @candidate_specification = CandidateSpecificationForm.new(@vacancy)
  end

  def submit_step_2; end

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

  def vacancy_id
    params.permit![:vacancy_id]
  end
end
