require "google/apis/drive_v3"

class Publishers::Vacancies::DocumentsController < Publishers::Vacancies::BaseController
  helper_method :form, :new_documents_form

  before_action :complete_step, unless: :document_added?, only: %i[create]

  def show
    if params[:publishers_job_listing_documents_form] && (form.invalid? && params[:publishers_job_listing_documents_form][:additional_document] == "true")
      render "publishers/vacancies/build/documents"
      return
    end

    return redirect_to organisation_job_review_path(vacancy.id) if form.upload_additional_document == "false"
  end

  def new_documents_form
    @new_documents_form ||= Publishers::JobListing::NewDocumentsForm.new(new_documents_form_params)
  end

  def new_documents_form_params
    (params[:publishers_job_listing_new_documents_form] || params).permit(documents: [])
  end

  def create
    if new_documents_form.invalid?
      render :show
      return
    end

    new_documents_form.valid_documents.each do |document|
      vacancy.supporting_documents.attach(document)
      send_event(:supporting_document_created, document.original_filename, document.size, document.content_type)
    end

    # So they are taken back to the show or review page upon clicking the back link, even after creating or deleting a document
    if params[:publishers_job_listing_documents_form]
      @back_link_destination = if params[:publishers_job_listing_documents_form][:back_to_review]
                                 :review
                               elsif params[:publishers_job_listing_documents_form][:back_to_show]
                                 :show
                               end

      params["back_to_#{@back_link_destination}"] = "true" if @back_link_destination
    end

    redirect_to organisation_job_build_path(vacancy.id, :documents)
  end

  def destroy
    document = vacancy.supporting_documents.find(params[:id])
    document.purge_later
    send_event(:supporting_document_deleted, document.filename, document.byte_size, document.content_type)

    redirect_to organisation_job_build_path(vacancy.id, :documents, back_to_review: params[:back_to_review], back_to_show: params[:back_to_show]), flash: {
      success: t("jobs.file_delete_success_message", filename: document.filename),
    }
  end

  private

  def step
    :documents
  end

  def form
    @form ||= Publishers::JobListing::DocumentsForm.new(documents_form_params, vacancy)
  end

  def documents_form_params
    (params[:publishers_job_listing_documents_form] || params).permit(:upload_additional_document)
  end

  def complete_step
    return if form.invalid?

    vacancy.update(completed_steps: completed_steps)

    redirect_to_next_step
  end

  def document_added?
    documents_form_params[:documents].present?
  end

  def send_event(event_type, name, size, content_type)
    fail_safe do
      request_event.trigger(
        event_type,
        vacancy_id: StringAnonymiser.new(vacancy.id),
        document_type: "supporting_document",
        name: name,
        size: size,
        content_type: content_type,
      )
    end
  end
end
