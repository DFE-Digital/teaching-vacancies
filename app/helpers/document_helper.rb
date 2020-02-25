module DocumentHelper
  def document_remove_link(document)
    link_to t('jobs.upload_documents_table.actions.remove'),
            document_school_job_path(id: document.id),
            class: 'js-delete-document govuk-link govuk-link--no-visited-state',
            data: {
              confirm: t('jobs.upload_documents_table.actions.are_you_sure', filename: document.name),
              disable_with: t('jobs.upload_documents_table.actions.removing')
            },
            method: :delete
  end
end
