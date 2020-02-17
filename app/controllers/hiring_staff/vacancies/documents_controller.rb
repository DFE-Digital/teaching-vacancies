require 'google/apis/drive_v3'

class HiringStaff::Vacancies::DocumentsController < HiringStaff::Vacancies::ApplicationController
  before_action :school, :redirect_unless_vacancy_session_id, only: %i[index create]
  before_action :redirect_if_no_supporting_documents, only: %i[index create]
  before_action :redirect_to_next_step_if_save_and_continue, only: :create

  def index
    @documents_form = DocumentsForm.new
    @vacancy = Vacancy.find(session[:vacancy_attributes]['id'])
  end

  def create
    @documents_form = DocumentsForm.new
    @vacancy = add_documents(process_documents(documents_form_params))
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

  def add_documents(documents_attributes)
    vacancy ||= school.vacancies.find(session_vacancy_id)
    documents_attributes.each do |document|
      vacancy.documents.create(document)
    end
    vacancy
  end

  def process_documents(params)
    @file_size_limit = 10 # MB
    @errors = false
    documents_array = []
    if params[:documents]&.any?
      params[:documents].each do |document_params|
        document_hash = upload_document(document_params)
        unless @errors
          documents_array << document_hash
        end
      end
    end
    documents_array
  end

  def upload_document(document_params)
    document_upload = DocumentUpload.new(
      upload_path: document_params.tempfile.path,
      name: document_params.original_filename
    )
    if document_params.size / 1024.0 / 1024.0 > @file_size_limit
      file_size_error(document_params.original_filename)
    end
    unless @errors
      document_upload.upload
      unless document_upload.safe_download
        virus_error(document_params.original_filename)
      end
      create_document_hash(document_params, document_upload)
    end
  end

  def file_size_error(filename)
    @errors = true
    @documents_form.errors.add(
      :base, t('jobs.file_size_error_message', filename: filename, size_limit: @file_size_limit)
    )
    @documents_form.errors.add(:documents, t('jobs.file_input_error_message'))
  end

  def virus_error(filename)
    @errors = true
    @documents_form.errors.add(:base, t('jobs.file_virus_error_message', filename: filename))
    @documents_form.errors.add(:documents, t('jobs.file_input_error_message'))
  end

  def create_document_hash(params, upload)
    {
      name: params.original_filename,
      size: Integer(params.size),
      content_type: params.content_type,
      download_url: upload.uploaded.web_content_link,
      google_drive_id: upload.uploaded.id
    }
  end
end
