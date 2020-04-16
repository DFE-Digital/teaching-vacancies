require 'google/apis/drive_v3'

class HiringStaff::Vacancies::DocumentsController < HiringStaff::Vacancies::ApplicationController
  FILE_SIZE_LIMIT = 10.megabytes

  before_action :redirect_unless_vacancy
  before_action :redirect_unless_supporting_documents
  before_action :redirect_to_next_step_if_save_and_continue, only: %i[create]

  before_action :set_documents_form, only: %i[show create]
  before_action :set_documents, only: %i[show create destroy]

  def show; end

  def create
    process_documents.each do |document|
      @documents.create(document)
    end

    render :show
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
      redirect_to school_job_documents_path(@vacancy.id)
    end
  end

  private

  def set_documents_form
    @documents_form = DocumentsForm.new
  end

  def set_documents
    @documents = @vacancy.documents
  end

  def documents_form_params
    params.require(:documents_form).permit(documents: [])
  end

  def redirect_unless_supporting_documents
    if params[:change] && !@vacancy.supporting_documents
      @vacancy.supporting_documents = 'yes'
      @vacancy.save
    end

    redirect_to supporting_documents_school_job_path unless @vacancy.supporting_documents
  end

  def next_step
    application_details_school_job_path
  end

  def redirect_to_next_step_if_save_and_continue
    if params[:commit] == I18n.t('buttons.save_and_continue')
      session[:clicked_continue_at_school_job_documents_path] = true
      redirect_to_next_step(@vacancy)
    elsif params[:commit] == I18n.t('buttons.update_job')
      redirect_to edit_school_job_path(@vacancy.id), success: I18n.t('messages.jobs.updated')
    elsif params[:commit] == I18n.t('buttons.save_and_return')
      redirect_to_school_draft_jobs(@vacancy)
    end
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

    document_attributes(document_params, document_upload) unless errors_on_file?(document_params.original_filename)
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
