class Vacancies::CandidateSpecificationController < Vacancies::ApplicationController
  before_action :school

  def new
    redirect_to job_specification_school_vacancy_path(school_id: school.id) unless session_vacancy_id

    @candidate_specification_form = ::CandidateSpecificationForm.new(session[:vacancy_attributes])
    @candidate_specification_form.valid? if session[:current_step].eql?('step_2')
  end

  def create
    @candidate_specification_form = CandidateSpecificationForm.new(candidate_specification_form)
    store_vacancy_attributes(@candidate_specification_form.vacancy.attributes.compact!)

    if @candidate_specification_form.valid?
      update_vacancy(candidate_specification_form)

      redirect_to step_3_school_vacancies_path(school_id: @school.id)
    else
      session[:current_step] = :step_2
      redirect_to candidate_specification_school_vacancy_path(school_id: @school.id)
    end
  end

  private

  def candidate_specification_form
    params.require(:candidate_specification_form).permit(:essential_requirements, :education,
                                                         :qualifications, :experience)
  end

end
