require "google/apis/drive_v3"

class Publishers::Vacancies::DocumentsController < Publishers::Vacancies::BaseController
  skip_before_action :verify_authenticity_token,
                     only: %i[upload_file delete_uploaded_file]

  def index
    @documents_form = Publishers::JobListing::DocumentsForm.new(documents_form_params, vacancy)
  end

  def new
    @documents_form = Publishers::JobListing::DocumentsForm.new(documents_form_params, vacancy)
  end

  def create
    @documents_form = Publishers::JobListing::DocumentsForm.new(documents_form_params.merge(supporting_documents: vacancy.supporting_documents), vacancy)
    if @documents_form.valid?
      vacancy.update(@documents_form.params_to_save)

      render :index
    else
      render :new
    end
  end

  def destroy
    document = vacancy.supporting_documents.find(params[:id])
    document.purge_later
    send_dfe_analytics_event(:supporting_document_deleted, document.filename, document.byte_size, document.content_type)

    redirect_to after_document_delete_path, flash: { success: t("jobs.file_delete_success_message", filename: document.filename) }
  end

  # These 2 methods support that MoJ multi-document upload component
  def upload_file
    @document = params.require(:documents)

    respond_to do |format|
      if vacancy.supporting_documents.attach(@document)
        send_dfe_analytics_event(:supporting_document_created, @document.original_filename, @document.size, @document.content_type)
        format.json { render "upload_success" }
      else
        format.json { render "upload_error" }
      end
    end
  end

  def delete_uploaded_file
    filename = params.require(:delete)
    vacancy.supporting_documents.select { |d| d.filename == filename }.each do |document|
      document.purge
      send_dfe_analytics_event(:supporting_document_deleted, document.filename, document.byte_size, document.content_type)
    end

    respond_to(&:json)
  end

  private

  def step
    :documents
  end

  def documents_form_params
    (params[:publishers_job_listing_documents_form] || params)
      .permit(supporting_documents: [])
      .merge(completed_steps: completed_steps)
  end

  def after_document_delete_path
    if vacancy.supporting_documents.none?
      organisation_job_build_path(vacancy.id,
                                  :include_additional_documents,
                                  back_to_review: params[:back_to_review],
                                  back_to_show: params[:back_to_show])
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
        .with_data(data: {
          vacancy_id: vacancy.id,
          document_type: "supporting_document",
          name: name,
          size: size,
          content_type: content_type,
        })

      DfE::Analytics::SendEvents.do([event])
    end
  end
end
