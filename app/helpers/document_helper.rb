module DocumentHelper
  def document_remove_link(document)
    link_to t("jobs.upload_documents_table.actions.remove"),
            "#",
            class: "govuk-link govuk-link--no-visited-state",
            data: {
              delete_path: organisation_job_documents_path(id: document.id, job_id: document.vacancy_id),
              document_id: document.id,
              file_name: document[:name],
              target: "modal-default",
              toggle: "modal",
            }
  end
end
