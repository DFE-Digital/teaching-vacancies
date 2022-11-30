class Publishers::JobListing::DocumentsForm < Publishers::JobListing::UploadBaseForm
  validate :document_presence
  validate :valid_documents

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

  def params_to_save
    { completed_steps: params[:completed_steps] }
  end

  private

  def document_presence
    return unless vacancy.include_additional_documents
    return if documents.present?

    errors.add(:documents, :blank) unless vacancy.supporting_documents.any?
  end
end
