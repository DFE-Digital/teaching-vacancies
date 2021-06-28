class MigrateVacancyDocumentsToActiveStorageJob < ApplicationJob
  queue_as :low

  # Most failures we encounter are likely to be terminal, so stop it from ballooning up retries
  sidekiq_options retry: false
  discard_on StandardError do |_job, err|
    Rollbar.error(err)
  end

  def perform(vacancy_id)
    vacancy = Vacancy.includes(:documents).with_attached_supporting_documents.find(vacancy_id)
    vacancy.supporting_documents.purge

    vacancy.documents.each { |document| migrate_document(vacancy, document) }
  end

  private

  def migrate_document(vacancy, document)
    Rails.logger.info("Migrating document #{document.id} (GDrive ID: #{document.google_drive_id})")

    Tempfile.create(binmode: true) do |local_file|
      # Download file from Google Drive into the tempfile
      drive_service.get_file(document.google_drive_id, download_dest: local_file.path)

      EventContext.suppress_events do
        # Attach file to the vacancy's supporting documents using ActiveStorage
        vacancy.supporting_documents.attach(
          io: local_file,
          filename: document.name,
          content_type: document.content_type,
        )
      end
    end

    # Verify the attachment was successful by trying to find it again
    fail_integrity_check!(vacancy, document) unless existing_attachment?(vacancy, document)
  rescue StandardError => e
    Rollbar.error(e)
  end

  def existing_attachment?(vacancy, document)
    vacancy.supporting_documents.reload.any? do |supporting_doc|
      supporting_doc.filename == document.name &&
        supporting_doc.byte_size == document.size &&
        supporting_doc.content_type == document.content_type
    end
  end

  def fail_integrity_check!(vacancy, document)
    doc_details = vacancy.supporting_documents.map do |sd|
      "#{sd.filename} (size: #{sd.byte_size}, type: #{sd.content_type}"
    end

    Rollbar.error(
      "Failed to verify integrity of migrated document #{document.id}",
      vacancy: vacancy.id,
      google_drive_id: document.google_drive_id,
      document_name: document.name,
      document_size: document.size,
      document_content_type: document.content_type,
      supporting_documents_details: doc_details,
    )
  end

  def drive_service
    @drive_service = Google::Apis::DriveV3::DriveService.new
  end
end
