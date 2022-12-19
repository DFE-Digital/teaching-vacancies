class Publishers::Organisation::ImageUploadBaseForm < BaseForm
  FILE_SIZE_LIMIT = 5.megabytes
  LOGO_DIMENSIONS = [300, 300]
  CONTENT_TYPES_ALLOWED = %w[
    image/jpeg
    image/png
  ].freeze

  private

  def valid_file_size?(image)
    return true if image.size <= FILE_SIZE_LIMIT

    errors.add(
      file_upload_field_name,
      I18n.t(
        "jobs.file_size_error_message",
        filename: image.original_filename,
        size_limit: ActiveSupport::NumberHelper.number_to_human_size(FILE_SIZE_LIMIT),
      ),
    )
    false
  end

  def valid_image_dimensions?(image)
    unless FastImage.size(image) == LOGO_DIMENSIONS
      Rails.logger.warn("Attempted to upload '#{image.original_filename}'. This image's dimensions are too large")
      errors.add(file_upload_field_name, I18n.t("jobs.image_dimension_error_message", filename: image.original_filename))
    end
  end

  def valid_file_type?(image)
    content_type = MimeMagic.by_magic(image.tempfile)&.type
    return true if CONTENT_TYPES_ALLOWED.include?(content_type)

    Rails.logger.warn("Attempted to upload '#{image.original_filename}' with forbidden image type '#{content_type}'")
    errors.add(file_upload_field_name, I18n.t("jobs.file_type_error_message", filename: image.original_filename))
    false
  end

  def virus_free?(image)
    return true if Publishers::DocumentVirusCheck.new(image.tempfile).safe?

    Rails.logger.warn("Attempted to upload '#{image.original_filename}' but Google Drive virus check failed")
    errors.add(file_upload_field_name, I18n.t("jobs.file_virus_error_message", filename: image.original_filename))
    false
  end
end
