class DocumentsController < ApplicationController
  def show
    document = Document.find(params[:id])
    request_event.trigger(:vacancy_document_downloaded,
                          vacancy_id: StringAnonymiser.new(document.vacancy.id),
                          document_id: StringAnonymiser.new(document.id),
                          filename: document.name)
    redirect_to(document.download_url)
  end
end
