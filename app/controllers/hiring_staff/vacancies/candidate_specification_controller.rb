class HiringStaff::Vacancies::CandidateSpecificationController < HiringStaff::Vacancies::ApplicationController
  before_action :school, :redirect_unless_vacancy_session_id, only: %i[new create]

  def new
    redirect_to job_specification_school_job_path unless session_vacancy_id

    @candidate_specification_form = ::CandidateSpecificationForm.new(session[:vacancy_attributes])
    @candidate_specification_form.valid? if %i[step_2 review].include?(session[:current_step])
  end

  def create
    @candidate_specification_form = CandidateSpecificationForm.new(candidate_specification_form)
    store_vacancy_attributes(@candidate_specification_form.vacancy)

    if @candidate_specification_form.valid?
      vacancy = update_vacancy(candidate_specification_form)
      return redirect_to_next_step(vacancy)
    end

    session[:current_step] = :step_2 unless session[:current_step].eql?(:review)
    redirect_to candidate_specification_school_job_path(anchor: 'errors')
  end

  def edit
    vacancy_attributes = source_update? ? session[:vacancy_attributes] : retrieve_job_from_db

    @school = school
    @candidate_specification_form = CandidateSpecificationForm.new(vacancy_attributes)
    @candidate_specification_form.valid?
  end

  def update
    vacancy = school.vacancies.published.find(vacancy_id)
    @candidate_specification_form = CandidateSpecificationForm.new(candidate_specification_form)
    @candidate_specification_form.id = vacancy.id

    if @candidate_specification_form.valid?
      reset_session_vacancy!
      update_vacancy(candidate_specification_form, vacancy)
      update_google_index(vacancy) if vacancy.listed?
      redirect_to edit_school_job_path(vacancy.id), notice: I18n.t('messages.jobs.updated')
    else
      store_vacancy_attributes(@candidate_specification_form.vacancy)
      redirect_to edit_school_job_candidate_specification_path(vacancy.id,
                                                               anchor: 'errors',
                                                               source: 'update')
    end
  end

  private

  def candidate_specification_form
    params.require(:candidate_specification_form).permit(:education, :qualifications, :experience)
  end

  def next_step
    application_details_school_job_path
  end
end
