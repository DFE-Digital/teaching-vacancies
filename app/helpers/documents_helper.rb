module DocumentsHelper
  def remove_document_link(document, vacancy)
    govuk_link_to organisation_job_document_path(id: document.id, job_id: vacancy.id, back_to_review: params[:back_to_review], back_to_show: params[:back_to_show]), method: :delete do
      safe_join [t("jobs.upload_documents_table.actions.delete"),
                 tag.span(" #{document.filename} supporting document", class: "govuk-visually-hidden")]
    end
  end

  def remove_application_form_link
    # See commit message for 1aa28cce3239c42b1af23d61ae08add3e8c51e5e for context
    govuk_link_to organisation_job_build_path(vacancy.id, :application_form, application_form_staged_for_replacement: true, back_to_review: params[:back_to_review], back_to_show: params[:back_to_show]) do
      safe_join [t("jobs.upload_documents_table.actions.delete"), tag.span("application form", class: "govuk-visually-hidden")]
    end
  end
end
