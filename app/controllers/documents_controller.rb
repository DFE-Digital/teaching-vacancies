class DocumentsController < ApplicationController
  def show
    send_custom_event
    redirect_to file, status: :moved_permanently
  end

  private

  def vacancy
    @vacancy ||= Vacancy.friendly.find(params[:job_id])
  end

  def application_form?
    vacancy.application_form.id == params[:id]
  end

  def file
    @file ||= document_or_application_form
  end

  def document_or_application_form
    return vacancy.application_form if application_form?

    vacancy.supporting_documents.find_by!(id: params[:id])
  end

  def send_custom_event
    event = DfE::Analytics::Event.new
      .with_type(:vacancy_document_downloaded)
      .with_request_details(request)
      .with_response_details(response)
      .with_user(current_user)
      .with_data(data: { vacancy_id: vacancy.id,
                         document_type: application_form? ? :application_form : :supporting_document,
                         document_id: file.id,
                         filename: file.filename })

    DfE::Analytics::SendEvents.do([event])
  end
end
