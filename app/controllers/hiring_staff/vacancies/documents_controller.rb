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
    file_size_limit = 10 # MB
    documents_array = []

    if params[:documents]&.any?
      params[:documents].each do |document_params|
        document_upload = DocumentUpload.new(
          upload_path: document_params.tempfile.path, 
          name: document_params.original_filename
        )
        document_upload.upload

        errors = false
        document_hash = {}
        document_hash[:name] = document_params.original_filename
        document_hash[:size] = Integer(document_params.size)
        document_hash[:content_type] = document_params.content_type
        document_hash[:download_url] = document_upload.uploaded.web_content_link
        document_hash[:google_drive_id] = document_upload.uploaded.id

        if document_params.size / 1024.0 / 1024.0 > file_size_limit
          errors = true
          @documents_form.errors.add(:base, "#{document_params.original_filename} must be smaller than #{file_size_limit} MB")
          @documents_form.errors.add(:documents, t('jobs.file_input_error_message'))
        end

        unless document_upload.safe_download
          errors = true
          @documents_form.errors.add(:base, "#{document_params.original_filename} contains a virus")
          @documents_form.errors.add(:documents, t('jobs.file_input_error_message'))
        end

        unless errors
          documents_array << document_hash
        end
      end
    end

    documents_array
  end
end
