class MigrateDocumentToActiveStorageJob < ApplicationJob
  class MigrationIntegrityError < RuntimeError; end

  queue_as :low
  discard_on MigrationIntegrityError

  def perform(document_id)
    document = Document.includes(:vacancy).find(document_id)

    if existing_attachment?(document)
      Rails.logger.info("Skipped migrating document #{document_id} as it already exists in AS")
      return
    end

    Rails.logger.info("Migrating document #{document.id} (GDrive ID: #{document.google_drive_id})")

    Tempfile.create(binmode: true) do |local_file|
      # Download file from Google Drive into the tempfile
      drive_service.get_file(
        document.google_drive_id,
        download_dest: local_file.path,
      )

      EventContext.suppress_events do
        # Attach file to the vacancy's supporting documents using ActiveStorage
        document.vacancy.supporting_documents.attach(
          io: local_file,
          filename: document.name,
          content_type: document.content_type,
        )
      end
    end

    # Verify the attachment was successful by trying to find it again
    fail_integrity_check!(document) unless existing_attachment?(document)
  end

  private

  def existing_attachment?(document)
    document.vacancy.supporting_documents.reload.any? do |supporting_doc|
      supporting_doc.filename == document.name &&
        supporting_doc.byte_size == document.size &&
        supporting_doc.content_type == document.content_type
    end
  end

  def fail_integrity_check!(document)
    doc_details = document.vacancy.supporting_documents.map do |sd|
      "#{sd.filename} (size: #{sd.byte_size}, type: #{sd.content_type}"
    end

    Rollbar.error(
      "Failed to verify integrity of migrated document #{document_id}",
      vacancy: document.vacancy_id,
      google_drive_id: doc.google_drive_id,
      document_name: document.name,
      document_size: document.size,
      document_content_type: document.content_type,
      supporting_documents_details: doc_details,
    )
    raise MigrationIntegrityError
  end

  def drive_service
    @drive_service = Google::Apis::DriveV3::DriveService.new
  end
end
