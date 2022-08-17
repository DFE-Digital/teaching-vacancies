class Publishers::JobListing::DocumentsForm < Publishers::JobListing::UploadBaseForm
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

  validate :document_presence

  attr_accessor :documents

  def self.fields
    []
  end

  def self.optional?
    false
  end

  def valid_documents
    @valid_documents ||= documents&.select { |doc| valid_file_size?(doc) && valid_file_type?(doc) && virus_free?(doc) } || []
  end

  def file_upload_field_name
    :documents
  end

  private

  def content_types_allowed
    CONTENT_TYPES_ALLOWED
  end

  def document_presence
    return unless vacancy.include_additional_documents

    errors.add(:documents, :blank) unless vacancy.supporting_documents.any?
  end
end
