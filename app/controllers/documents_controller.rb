class DocumentsController < ApplicationController
  def show
    document = vacancy.supporting_documents.find(params[:id])

    request_event.trigger(:vacancy_document_downloaded, vacancy_id: vacancy.id, document_id: document.id, filename: document.filename)
    redirect_to document
  end

  private

  def vacancy
    @vacancy = Vacancy.listed.friendly.find(params[:job_id])
  end
end
