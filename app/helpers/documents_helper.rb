module DocumentsHelper
  def remove_document_link(document, vacancy)
    govuk_link_to organisation_job_documents_path(id: document.id, job_id: vacancy.id), method: :delete do
      safe_join [t("jobs.upload_documents_table.actions.remove"),
                 tag.span(" #{document.filename} supporting document", class: "govuk-visually-hidden")]
    end
  end
end
