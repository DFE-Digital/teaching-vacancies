require 'google/apis/drive_v3'

class HiringStaff::Vacancies::DocumentsController < HiringStaff::Vacancies::ApplicationController
  FILE_SIZE_LIMIT = 10.megabytes

  before_action :redirect_unless_vacancy_session_id, only: %i[index create destroy]
  before_action :redirect_if_no_supporting_documents, only: %i[index create destroy]
  before_action :redirect_to_next_step_if_save_and_continue, only: %i[create destroy]

  before_action :set_documents_form, only: %i[index create]
  before_action :set_documents, only: %i[index create destroy]

  def index; end

  def create
    process_documents.each do |document|
      @documents.create(document)
    end

    render :index
  end

  def destroy
    document = @documents.find(params[:id])
    delete_operation_status = DocumentDelete.new(document).delete
    flash_type = delete_operation_status ? :success : :error
    flash_message = I18n.t("jobs.file_delete_#{flash_type}_message", filename: document.name)

    if request.xhr?
      flash.now[flash_type] = flash_message
      render :destroy, layout: false, status: delete_operation_status ? :ok : :bad_request
    else
      flash[flash_type] = flash_message
      redirect_to documents_school_job_path
    end
  end

  private

  def set_documents_form
    @documents_form = DocumentsForm.new
  end

  def vacancy
    current_school.vacancies.find(session_vacancy_id)
  end

  def set_documents
    @documents = vacancy.documents
  end

  def documents_form_params
    params.require(:documents_form).permit(documents: [])
  end

  def redirect_if_no_supporting_documents
    supporting_documents = session[:vacancy_attributes]['supporting_documents']
    redirect_to supporting_documents_school_job_path unless supporting_documents
  end

  def next_step
    application_details_school_job_path
  end

  def redirect_to_next_step_if_save_and_continue
    redirect_to_next_step(vacancy) if params[:commit] == 'Save and continue'
  end

  def process_documents
    documents_form_params[:documents].each_with_object([]) do |document_params, documents_array|
      document_hash = upload_document(document_params)
      next if errors_on_file?(document_params.original_filename)

      documents_array << document_hash
    end
  end

  def upload_document(document_params)
    add_file_size_error(document_params.original_filename) if document_params.size > FILE_SIZE_LIMIT

    document_upload = DocumentUpload.new(
      upload_path: document_params.tempfile.path,
      name: document_params.original_filename
    )

    return if errors_on_file?(document_params.original_filename)

    document_upload.upload

    add_google_error(document_params.original_filename) if document_upload.google_error
    add_virus_error(document_params.original_filename) unless document_upload.safe_download

    document_attributes(document_params, document_upload)
  end

  def add_file_size_error(filename)
    @documents_form.errors.add(
      :documents,
      t('jobs.file_size_error_message',
      filename: filename,
      size_limit: helpers.number_to_human_size(FILE_SIZE_LIMIT))
    )
  end

  def add_google_error(filename)
    @documents_form.errors.add(:documents, t('jobs.file_google_error_message', filename: filename))
  end

  def add_virus_error(filename)
    @documents_form.errors.add(:documents, t('jobs.file_virus_error_message', filename: filename))
  end

  def errors_on_file?(filename)
    @documents_form.errors.messages.values.join(' ').include?(filename)
  end

  def document_attributes(params, upload)
    {
      name: params.original_filename,
      size: Integer(params.size),
      content_type: params.content_type,
      download_url: upload.uploaded.web_content_link,
      google_drive_id: upload.uploaded.id
    }
  end
end
