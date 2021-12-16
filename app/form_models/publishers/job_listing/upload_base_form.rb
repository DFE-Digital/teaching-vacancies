class Publishers::JobListing::UploadBaseForm < Publishers::JobListing::VacancyForm
  CONTENT_TYPES_ALLOWED = %w[
    application/pdf
    image/jpeg
    image/png
    video/mp4
    application/msword
    application/vnd.ms-excel
    application/vnd.ms-powerpoint
    application/vnd.openxmlformats-officedocument.wordprocessingml.document
    application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
    application/vnd.openxmlformats-officedocument.presentationml.presentation
  ].freeze

  FILE_SIZE_LIMIT = 10.megabytes

  private

  def valid_file_size?(document)
    return true if document.size <= FILE_SIZE_LIMIT

    errors.add(
      :documents,
      I18n.t(
        "jobs.file_size_error_message",
        filename: document.original_filename,
        size_limit: ActiveSupport::NumberHelper.number_to_human_size(FILE_SIZE_LIMIT),
      ),
    )
    false
  end

  def valid_file_type?(document)
    content_type = MimeMagic.by_magic(document.tempfile)&.type
    return true if CONTENT_TYPES_ALLOWED.include?(content_type)

    Rails.logger.warn("Attempted to upload '#{document.original_filename}' with forbidden file type '#{content_type}'")
    errors.add(:documents, I18n.t("jobs.file_type_error_message", filename: document.original_filename))
    false
  end

  def virus_free?(document)
    return true if Publishers::DocumentVirusCheck.new(document.tempfile).safe?

    Rails.logger.warn("Attempted to upload '#{document.original_filename}' but Google Drive virus check failed")
    errors.add(:documents, I18n.t("jobs.file_virus_error_message", filename: document.original_filename))
    false
  end
end
