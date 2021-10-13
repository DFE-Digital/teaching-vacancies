class DocumentsController < ApplicationController
  def show
    request_event.trigger(:vacancy_document_downloaded,
                          vacancy_id: StringAnonymiser.new(vacancy.id),
                          document_id: StringAnonymiser.new(document.id),
                          filename: document.filename)
    redirect_to document, status: :moved_permanently
  end

  private

  def vacancy
    @vacancy ||= Vacancy.friendly.find(params[:job_id])
  end

  def document
    @document ||= vacancy.supporting_documents.find(params[:id])
  end
end
