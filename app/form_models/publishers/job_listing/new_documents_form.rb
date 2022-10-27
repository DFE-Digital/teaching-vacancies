class Publishers::JobListing::NewDocumentsForm < Publishers::JobListing::UploadBaseForm
  CONTENT_TYPES_ALLOWED = %w[
    application/pdf
    application/msword
    application/vnd.openxmlformats-officedocument.wordprocessingml.document
  ].freeze

  validates :documents, presence: true
  validate :valid_documents

  attr_accessor :documents

  def self.fields
    %i[documents]
  end

  def valid_documents
    documents&.select { |doc| valid_file_size?(doc) && valid_file_type?(doc) && virus_free?(doc) } || []
  end

  def file_upload_field_name
    :documents
  end

  private

  def content_types_allowed
    CONTENT_TYPES_ALLOWED
  end
end
