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

  def valid_file_size?(file)
    return true if file.size <= FILE_SIZE_LIMIT

    errors.add(
      file_upload_field_name,
      I18n.t(
        "jobs.file_size_error_message",
        filename: file.original_filename,
        size_limit: ActiveSupport::NumberHelper.number_to_human_size(FILE_SIZE_LIMIT),
      ),
    )
    false
  end

  def valid_file_type?(file)
    content_type = MimeMagic.by_magic(file.tempfile)&.type
    return true if CONTENT_TYPES_ALLOWED.include?(content_type)

    Rails.logger.warn("Attempted to upload '#{file.original_filename}' with forbidden file type '#{content_type}'")
    errors.add(file_upload_field_name, I18n.t("jobs.file_type_error_message", filename: file.original_filename))
    false
  end

  def virus_free?(file)
    return true if Publishers::DocumentVirusCheck.new(file.tempfile).safe?

    Rails.logger.warn("Attempted to upload '#{file.original_filename}' but Google Drive virus check failed")
    errors.add(file_upload_field_name, I18n.t("jobs.file_virus_error_message", filename: file.original_filename))
    false
  end
end
