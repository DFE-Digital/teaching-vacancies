require "google/apis/drive_v3"

class Publishers::Vacancies::DocumentsController < Publishers::Vacancies::BaseController
  helper_method :documents_form, :confirmation_form

  def create
    if documents_form.valid?
      documents_form.documents.each do |document|
        vacancy.supporting_documents.attach(document)
        send_event(:supporting_document_created, document.original_filename, document.size, document.content_type)
        send_dfe_analytics_event(:supporting_document_created, document.original_filename, document.size, document.content_type)
      end

      vacancy.update(documents_form.params_to_save)

      render :index
    else
      render :new
    end
  end

  def destroy
    document = vacancy.supporting_documents.find(params[:id])
    document.purge_later
    send_event(:supporting_document_deleted, document.filename, document.byte_size, document.content_type)
    send_dfe_analytics_event(:supporting_document_deleted, document.filename, document.byte_size, document.content_type)

    redirect_to after_document_delete_path, flash: { success: t("jobs.file_delete_success_message", filename: document.filename) }
  end

  def confirm
    if confirmation_form.valid?
      return redirect_to_next_step unless uploading_more_documents?

      redirect_to new_organisation_job_document_path(vacancy.id)
    else
      render :index
    end
  end

  private

  def step
    :documents
  end

  def documents_form
    @documents_form ||= Publishers::JobListing::DocumentsForm.new(documents_form_params, vacancy)
  end

  def documents_form_params
    (params[:publishers_job_listing_documents_form] || params)
      .permit(documents: [])
      .merge(completed_steps: completed_steps)
  end

  def confirmation_form
    @confirmation_form ||= Publishers::JobListing::DocumentsConfirmationForm.new(confirmation_form_params, vacancy)
  end

  def confirmation_form_params
    (params[:publishers_job_listing_documents_confirmation_form] || params)&.permit(:upload_additional_document)
  end

  def uploading_more_documents?
    confirmation_form_params[:upload_additional_document] == "true"
  end

  def after_document_delete_path
    if vacancy.supporting_documents.none?
      new_organisation_job_document_path(vacancy.id, back_to_review: params[:back_to_review], back_to_show: params[:back_to_show])
    else
      organisation_job_documents_path(vacancy.id, back_to_review: params[:back_to_review], back_to_show: params[:back_to_show])
    end
  end

  def send_dfe_analytics_event(event_type, name, size, content_type)
    fail_safe do
      event = DfE::Analytics::Event.new
        .with_type(event_type)
        .with_request_details(request)
        .with_response_details(response)
        .with_user(current_publisher)
        .with_data(
          vacancy_id: StringAnonymiser.new(vacancy.id),
          document_type: "supporting_document",
          name: name,
          size: size,
          content_type: content_type,
        )

      DfE::Analytics::SendEvents.do([event])
    end
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
