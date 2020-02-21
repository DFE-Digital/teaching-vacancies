require 'google/apis/drive_v3'

class HiringStaff::Vacancies::DocumentsController < HiringStaff::Vacancies::ApplicationController
  FILE_SIZE_LIMIT = 10.megabytes

  before_action :school, :redirect_unless_vacancy_session_id, only: %i[index create destroy]

  before_action :set_documents_form, only: %i[index create]
  before_action :set_vacancy, only: %i[index create destroy]
  before_action :set_documents, only: %i[index create destroy]

  before_action :redirect_if_no_supporting_documents, only: %i[index create destroy]
  before_action :redirect_to_next_step_if_save_and_continue, only: %i[create destroy]

  def index; end

  def create
    process_documents(documents_form_params).each do |document|
      @documents.create(document)
    end

    render :index
  end

  def destroy
    document = @documents.find(params[:id])

    if DocumentDelete.new(document).delete
      flash[:success] = I18n.t('jobs.file_delete_success_message', filename: document.name)
    else
      flash[:error] = I18n.t('jobs.file_delete_error_message', filename: document.name)
    end

    redirect_to documents_school_job_path
  end

  private

  def set_documents_form
    @documents_form = DocumentsForm.new
  end

  def set_vacancy
    @vacancy = school.vacancies.find(session_vacancy_id)
  end

  def set_documents
    @documents = @vacancy.documents
  end

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

  def process_documents(params)
    return [] if params[:documents].empty?

    params[:documents].each_with_object([]) do |document_params, documents_array|
      @errors = false
      document_hash = upload_document(document_params)
      next if @errors

      documents_array << document_hash
    end
  end

  def upload_document(document_params)
    if document_params.size > FILE_SIZE_LIMIT
      file_size_error(document_params.original_filename)
    end

    document_upload = DocumentUpload.new(
      upload_path: document_params.tempfile.path,
      name: document_params.original_filename
    )

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
      :base,
      t('jobs.file_size_error_message',
      filename: filename,
      size_limit: helpers.number_to_human_size(FILE_SIZE_LIMIT))
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
