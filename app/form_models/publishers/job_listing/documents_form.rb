class Publishers::JobListing::DocumentsForm < Publishers::JobListing::UploadBaseForm
  validates :upload_additional_document, inclusion: { in: [true, false, "true", "false"] }

  attr_accessor :upload_additional_document

  def self.fields
    []
  end

  def self.optional?
    false
  end

  def additional_document
    params[:additional_document] == "true"
  end
end
