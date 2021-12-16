class Publishers::JobListing::DocumentsForm < Publishers::JobListing::UploadBaseForm
  attr_accessor :documents

  def self.fields
    []
  end

  def valid_documents
    @valid_documents ||= documents&.select { |doc| valid_file_size?(doc) && valid_file_type?(doc) && virus_free?(doc) } || []
  end

  def file_upload_field_name
    :documents
  end
end
