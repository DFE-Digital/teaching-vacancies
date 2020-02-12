class HiringStaff::Vacancies::DocumentsController < HiringStaff::Vacancies::ApplicationController
  before_action :school, :redirect_unless_vacancy_session_id, only: %i[index create]
  before_action :redirect_if_no_supporting_documents, only: %i[index create]
  before_action :redirect_to_next_step_if_save_and_continue, only: :create

  def index
    @documents_form = DocumentsForm.new
  end

  def create
    @documents_form = DocumentsForm.new(documents_form_params)
    render :index
  end

  private

  def documents_form_params
    params.require(:documents_form).permit(documents: [])
  end

  def redirect_if_no_supporting_documents
    supporting_documents = session[:vacancy_attributes]['supporting_documents']
    redirect_to supporting_documents_school_job_path unless supporting_documents == 'yes'
  end

  def redirect_to_next_step_if_save_and_continue
    redirect_to application_details_school_job_path if params[:commit] == 'Save and continue'
  end
end
