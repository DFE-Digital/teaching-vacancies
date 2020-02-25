class HiringStaff::Vacancies::SupportingDocumentsController < HiringStaff::Vacancies::ApplicationController
  before_action :redirect_unless_vacancy_session_id, only: %i[new create]

  def new
    redirect_to job_specification_school_job_path unless session_vacancy_id

    @supporting_documents_form = SupportingDocumentsForm.new(session[:vacancy_attributes])
    @supporting_documents_form.valid? if %i[step_2_intro review].include?(session[:current_step])
  end

  def create
    @supporting_documents_form = SupportingDocumentsForm.new(supporting_documents_form_params)
    store_vacancy_attributes(@supporting_documents_form.vacancy.attributes)

    if @supporting_documents_form.valid?
      vacancy = update_vacancy(supporting_documents_form_params)
      return redirect_to_next_step(vacancy)
    end

    session[:current_step] = :step_2_intro unless session[:current_step].eql?(:review)
    redirect_to supporting_documents_school_job_path(anchor: 'errors')
  end

  private

  def supporting_documents_form_params
    (params[:supporting_documents_form] || params).permit(:supporting_documents)
  end

  def next_step
    @supporting_documents_form.supporting_documents == 'yes' ?
      documents_school_job_path : application_details_school_job_path
  end
end
