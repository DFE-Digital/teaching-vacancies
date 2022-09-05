module DocumentsHelper
  def remove_document_link(document, vacancy)
    govuk_link_to organisation_job_documents_path(id: document.id, job_id: vacancy.id, back_to_review: params[:back_to_review]), method: :delete do
      safe_join [t("jobs.upload_documents_table.actions.remove"),
                 tag.span(" #{document.filename} supporting document", class: "govuk-visually-hidden")]
    end
  end

  def remove_application_form_link(application_form, vacancy)
    govuk_link_to organisation_job_application_forms_path(id: application_form.id, job_id: vacancy.id, back_to_review: params[:back_to_review]), method: :delete do
      safe_join [t("jobs.upload_documents_table.actions.remove"),
                 tag.span(" #{application_form.filename} supporting document", class: "govuk-visually-hidden")]
    end
  end
end
