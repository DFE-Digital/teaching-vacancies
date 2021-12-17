class DocumentsController < ApplicationController
  def show
    request_event.trigger(:vacancy_document_downloaded,
                          vacancy_id: StringAnonymiser.new(file.id),
                          document_id: StringAnonymiser.new(file.id),
                          filename: file.filename)
    redirect_to file, status: :moved_permanently
  end

  private

  def vacancy
    @vacancy ||= Vacancy.friendly.find(params[:job_id])
  end

  def file
    @file ||= document_or_application_form
  end

  def document_or_application_form
    return vacancy.application_form if vacancy.application_form.id == params[:id]

    vacancy.supporting_documents.find_by(id: params[:id])
  end
end
