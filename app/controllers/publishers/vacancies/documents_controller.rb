require "google/apis/drive_v3"

class Publishers::Vacancies::DocumentsController < Publishers::Vacancies::BaseController
  helper_method :form

  before_action :redirect_to_next_step, only: %i[create]

  def create
    form.valid_documents.each do |document|
      vacancy.supporting_documents.attach(document)
      send_event(:supporting_document_created, document)
    end

    render :show
  end

  def destroy
    document = vacancy.supporting_documents.find(params[:id])
    document.purge_later
    send_event(:supporting_document_deleted, document)

    redirect_to organisation_job_documents_path(vacancy.id), flash: {
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
    (params[:publishers_job_listing_documents_form] || params).permit(documents: [])
  end

  def redirect_to_next_step
    return if documents_form_params[:documents]

    vacancy.update(completed_steps: completed_steps)
    if session[:current_step] == :review
      redirect_updated_job_with_message
    else
      redirect_to organisation_job_build_path(vacancy.id, :job_summary)
    end
  end

  def send_event(event_type, document)
    request_event.trigger(
      event_type,
      vacancy_id: StringAnonymiser.new(vacancy.id),
      document_type: "supporting_document",
      name: document.original_filename,
      size: document.size,
      content_type: document.content_type,
    )
  end
end
