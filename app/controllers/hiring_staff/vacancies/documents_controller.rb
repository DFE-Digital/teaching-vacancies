require 'google/apis/drive_v3'

class HiringStaff::Vacancies::DocumentsController < HiringStaff::Vacancies::ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :school, :redirect_unless_vacancy_session_id, only: %i[index create]

  def index
    unless session[:vacancy_attributes]['supporting_documents'] == 'yes'
      redirect_to supporting_documents_school_job_path
    end
  end

  def create
    redirect_to documents_school_job_path
  end
end
