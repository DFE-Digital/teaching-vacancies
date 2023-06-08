class Publishers::JobListing::DocumentsForm < Publishers::JobListing::VacancyForm
  validates :supporting_documents, form_file: true
  validate :document_presence

  attr_accessor :supporting_documents

  def self.fields
    [:supporting_documents]
  end

  def self.optional?
    false
  end

  def file_type
    :document
  end

  def content_types_allowed
    %w[application/pdf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document].freeze
  end

  def file_size_limit
    10.megabytes
  end

  def valid_file_types
    %i[PDF DOC DOCX]
  end

  def params_to_save
    { completed_steps: params[:completed_steps] }
  end

  private

  def document_presence
    return unless vacancy.include_additional_documents
    return if supporting_documents.present?

    errors.add(:supporting_documents, :blank)
  end
end
