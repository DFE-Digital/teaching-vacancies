require 'google/apis/drive_v3'

class HiringStaff::Vacancies::DocumentsController < HiringStaff::Vacancies::ApplicationController
  before_action :school, :redirect_unless_vacancy_session_id, only: %i[index create]

  def index
    unless session[:vacancy_attributes]['supporting_documents'] == 'yes'
      redirect_to supporting_documents_school_job_path
    end
    @documents_form = DocumentsForm.new(documents_form_params)
    @vacancy = Vacancy.find(session[:vacancy_attributes]['id'])
  end

  def create
    @documents_form = DocumentsForm.new()
    @vacancy = add_documents(documents_form_params(upload: true))

    render :index
  end

  private

  def upload(file_path, file_name)
    document_upload = DocumentUpload.new(upload_path: file_path, name: file_name)
    document_upload.upload_hiring_staff_document
    document_upload.set_public_permission_on_document
    document_upload.google_drive_virus_check
    document_upload
  end

  def documents_form_params(upload: false)
    if upload
      process_documents_params((params[:documents_form] || params).permit(documents: []))
    else
      (params[:documents_form] || params).permit(documents: [])
    end
  end

  def process_documents_params(valid_params)
    documents_array = []

    if valid_params[:documents]&.any?
      valid_params[:documents].each do |document_params|
        document_upload = upload(document_params.tempfile.path, document_params.original_filename)
        if document_upload.safe_download
          document_hash = {
            name: document_params.original_filename,
            size: Integer(document_params.size),
            content_type: document_params.content_type,
            download_url: document_upload.uploaded.web_content_link,
            google_drive_id: document_upload.uploaded.id
            # download_url: 'test_url',
            # google_drive_id: 'test_id'
          }
          documents_array << document_hash
        else
          @documents_form.errors.add(:base, "#{document_params.original_filename} contains a virus!")
          @documents_form.errors.add(:documents, 'The selected file(s) could not be uploaded!')
        end
      end
    end
    processed_params = {}
    processed_params[:documents_attributes] = documents_array
    processed_params
  end

  def add_documents(attributes)
    vacancy ||= school.vacancies.find(session_vacancy_id)
    attributes[:documents_attributes].each do |document|
      vacancy.documents.create(document)
    end
    vacancy
  end
end
