class DocumentsController < ApplicationController
  def show
    document = Document.find(params[:id])
    request_event.trigger(:vacancy_document_downloaded, vacancy_id: document.vacancy.id, document_id: document.id, filename: document.name)
    redirect_to(document.download_url)
  end
end
