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
    upload(params[:upload].tempfile.path)
    params[:upload].tempfile.delete

    if @document_upload.safe_download
      add_document_to_vacancy
      render json: @document_upload.uploaded.web_content_link
    else
      redirect_to documents_school_job_path
    end
  end

  private

  def upload(temp_file_path)
    @document_upload = DocumentUpload.new(upload_path: temp_file_path)
    @document_upload.upload_hiring_staff_document
    @document_upload.set_public_permission_on_document
    @document_upload.google_drive_virus_check
  end

  def add_document_to_vacancy
    @vac = Vacancy.find(session[:vacancy_attributes]['id'])
    @vac.documents.create(
      name: params[:upload].original_filename,
      size: params[:upload].size,
      content_type: params[:upload].content_type,
      download_url: @document_upload.uploaded.web_content_link,
      google_drive_id: @document_upload.uploaded.id
    )
  end
end
